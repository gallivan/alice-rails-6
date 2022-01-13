module Workers
  class CmeDAO

    CME_MAIN_IPA = '164.74.122.33' # production
    CME_BACK_IPA = '167.204.41.33' # backup

    @settlements

    def initialize
      @settlements = {}
    end

    attr_accessor :settlements

    def settlement_filename(code, date)
      # cme.settle.20190823.s.csv
      "/settle/#{code.downcase}.settle.#{date.strftime('%Y%m%d')}.s.csv"
    end

    def get_public_file(filename)
      Rails.logger.info "Downloading #{filename}"
      dnl_filename = "#{ENV['DNL_DIR']}/cme/#{File.basename(filename)}"
      unless File.exist? dnl_filename
        Rails.logger.info "Downloading to #{dnl_filename}"
        File.delete(dnl_filename) if File.exist?(dnl_filename)
        while true do
          begin
            Rails.logger.info "Net::FTP try file: #{filename}"
            Net::FTP.open('ftp.cmegroup.com') do |ftp|
              ftp.login
              ftp.getbinaryfile(filename, dnl_filename, 1024)
            end
            Rails.logger.info "Net::FTP got file: #{filename}"
            break
          rescue Exception => e
            msg = "FTP exception occurred: #{e.message}. Sleeping until #{Time.now + FILE_WAIT_INTERVAL}."
            EodMailer.alert(msg).deliver_now
            sleep FILE_WAIT_INTERVAL
          end
        end
      end
      dnl_filename
    end

    def augment_settlement_map(code, date)
      filename = settlement_filename(code, date)
      dnl_file = get_public_file(filename)
      map = {}
      File.open(dnl_file).readlines.each do |line|
        line.gsub!('"', '')
        fields = line.split(/,/)
        map[fields[2] + fields[5]] = line if fields[4] =~ /FUT/
      end
      @settlements[code] = map
    end

    def cme_code_for_claim(claim)
      system = System.where(code: 'CMESET').first
      claim_set = claim.claim_set
      claim_set_alias = (ClaimSetAlias.where claim_set_id: claim_set.id, system_id: system.id).first

      while claim_set_alias.blank?
        msg = "#{system.name} ClaimSetAlias missing for #{claim.code}."
        Rails.logger.warn msg
        EodMailer.alert(msg).deliver_now
        Rails.logger.warn "Sleeping until #{15.minutes.from_now}."
        sleep 900
        claim_set_alias = (ClaimSetAlias.where claim_set_id: claim_set.id, system_id: system.id).first
      end

      claim_set_alias.code
    end

    def set_marks(claims, date)
      code = claims.first.entity.code.downcase
      augment_settlement_map(code, date)
      claims.each do |claim|
        Rails.logger.info("Setting mark for #{claim.code} on #{date}")

        if claim.claim_set.code == 'CME:SR1'
          mat = (claim.claimable.expires_on - 1.months).strftime('%Y%m')
        elsif claim.claim_set.code == 'CME:SR3'
          mat = (claim.claimable.expires_on - 3.months).strftime('%Y%m')
        else
          mat = claim.claimable.expires_on.strftime('%Y%m')
        end

        sym = cme_code_for_claim(claim)
        tag = sym + mat

        if @settlements[code][tag].blank?
          Rails.logger.warn "No settlement for #{@settlements[code][tag]} "
        else
          ary = @settlements[code][tag].split(/,/)
          if claim.claim_marks.posted_on(date).blank?
            mark = BigDecimal(ary[13], 16)
            mark = mark * 100 if claim.entity.code =~ /CBT/ and sym =~ /^(S|C|W|KW)/
            begin
              ClaimMark.create! do |s|
                s.system_id = System.find_by_code('CMESET').id
                s.claim_id = claim.id
                s.posted_on = date
                s.mark = mark
                s.approved = false
              end
            rescue Exception => e
              Rails.logger.warn e.message
              Rails.logger.warn "Exception at #{Time.now}."
            end
          end
        end
      end
    end

  end
end