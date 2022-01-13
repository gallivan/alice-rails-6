module Builders

  class ClaimMarkBuilder

    def self.build_from_emm_stl_tt_file(date)
      filename = "#{ENV['STL_DIR']}/emm_stl_tt_#{date.strftime('%Y%m%d')}.txt"

      lines = File.open(filename).readlines
      lines.each do |line|

        q_code = quandl_code_for_claim(claim)

        claim_mark = ClaimMark.posted_on(date).posted_for(claim.id).first

        if claim_mark.blank?
          Rails.logger.info "Seek: code #{claim.code} key #{q_code}"
          try_quandl(claim, q_code, date)
        else
          msg = "Skip: code #{claim.code} key #{q_code} settled #{claim_mark.mark}"
          puts msg
          Rails.logger.info msg
        end

        list = line.split('|')
        puts list
      end
    end

  end

end