module Workers
  class GhfDAO

    GHF_MAIN_IPA = 'sftp.ghfinancials.com' # production
    # GHF_BACK_IPA = '167.204.41.33' # backup

    def get_file(filename)
      Rails.logger.info "get_file: #{filename}"
      raise "filename blank. Cannot get GHF file." if filename.blank?

      # username = ENV['SFTP_CME_USR']
      username = 'Eagle.Market.Makers'

      Rails.logger.info "Downloading #{filename}"

      dnl_filename = "#{ENV['DNL_DIR']}/ghf/#{filename}"
      Rails.logger.info "Downloading to #{dnl_filename}"
      File.delete(dnl_filename) if File.exist?(dnl_filename)

      while true do
        begin
          Rails.logger.info "Net::SFTP try file: #{filename}"
          Net::SFTP.start(GHF_MAIN_IPA, username, keys:['~/.ssh/ghfincial_sftp_private_key']) do |sftp|
            sftp.download!("Eagle.Market.Makers/foo", dnl_filename)
          end
          Rails.logger.info "Net::SFTP got file: #{filename}"
          break
        rescue Exception => e
          msg = "SFTP exception occurred: #{e.message}. Sleeping until #{Time.now + FILE_WAIT_INTERVAL}."
          EodMailer.alert(msg).deliver_now
          sleep FILE_WAIT_INTERVAL
        end
      end

      dnl_filename
    end

  end
end