=begin

NOTE THE TRAILING BLANKS - POPULATED FOR UNDERLYINGS - NOT HERE

RP330  03000       2016120201 SH   201703          00001420000348               # line length 80
RP330  03000       2016120201 KW   201703          00000920000005               # line length 80
RP330  03000       2016120201 KW   201705          00000500000060               # line length 80
RP330  03000       2016120201 07   201705          00000190000051               # line length 80
RP330  03000       2016120201 25   201612          00000050000002               # line length 80
RP330  03000       2016120201 SN   201707          00000200000000               # line length 80
RP353  03000       2016120202 ED   201809          00000020000000               # line length 80
RP330  03000       2016120201 06   201701          00003200000118               # line length 80
RP330  03000       2016120201 21   201612          00000130000006               # line length 80
RP330  03000       2016120201 CZ   201712          00000000000014               # line length 80
RP330  03000       2016120201 WH   201703          00000000000046               # line length 80
RP330  03000       2016120201 26   201703          00000000000001               # line length 80
RP330  03000       2016120201 21   201703          00000060000014               # line length 80
RP353  03000       2016120202 ED   201712          00000000000006               # line length 80
RP330  03000       2016120201 06   201705          00000000000005               # line length 80
RP330  03000       2016120201 SF   201701          00002830000147               # line length 80
RP330  03000       2016120201 07   201701          00021310001537               # line length 80
RP330  03000       2016120201 07   201707          00000050000020               # line length 80
RP353  03000       2016120202 ED   201706          00000000000054               # line length 80
RP330  03000       2016120201 KW   201707          00000140000091               # line length 80
RP330  03000       2016120201 06   201703          00000050000202               # line length 80
RP330  03000       2016120201 CK   201705          00000520000062               # line length 80
RP353  03000       2016120202 ED   201709          00000060000000               # line length 80
RP330  03000       2016120201 SK   201705          00000500000000               # line length 80
RP353  03000       2016120202 ED   201812          00000000000002               # line length 80
RP353  03000       2016120202 ED   201703          00000540000000               # line length 80
RP330  03000       2016120201 CH   201703          00000780000049               # line length 80
RP330  03000       2016120201 25   201703          00000020000005               # line length 80
RP330  03000       2016120201 CN   201707          00000000000038               # line length 80
RP330  03000       2016120201 07   201703          00015370002097               # line length 80
RP330  03000       2016120201 CU   201709          00000330000000               # line length 80
=end

require 'net/ftp'
require 'net/sftp'

# General description can be found at....
# http://www.cftc.gov/industryoversight/marketsurveillance/largetraderreportingprogram/index.htm

# Current reporting levels can be found at....
# https://www.ecfr.gov/cgi-bin/retrieveECFR?gp=&SID=970471b8455f4bab7db4110cfde50731&mc=true&r=SECTION&n=se17.1.15_103

module Workers
  class LargeTraderReport

    def compute(date_today)
      lines = []
      begin
        date_prior = StatementPosition.where('stated_on < ?', date_today).maximum(:stated_on)

        claim_codes = get_claim_codes(date_today, date_prior)

        claim_codes.each do |code|
          # TODO - there is a better way
          a, b = code.split(':')
          next unless a.match(/CME|CBT/)

          statement_position_today = get_statement_positions(code, date_today)
          statement_position_prior = get_statement_positions(code, date_prior)

          statement_position = get_reportable_statement_position(statement_position_today, statement_position_prior)

          statement_position = get_statement_position_dummy(date_today, code) if statement_position.blank?

          lines << add_line(statement_position)
        end

        lines.sort
      rescue Exception => e
        EodMailer.alert(e.message).deliver_now
      end
    end

    def reportable?(statement_position)
      return false if statement_position.blank?

      report_type = ReportType.find_by_code 'LTR'
      claim = Claim.find_by_code(statement_position.claim_code)
      claim_set = claim.claim_set

      target = "ClaimSet: #{claim_set.code} Claim: #{claim.code}"

      Rails.logger.info("CME LTR line for #{target}")

      begin
        if report_type.report_type_parameters.where("handle = ?", claim_set.code).blank?
        else
          qty = report_type.report_type_parameters.where("handle = ?", claim_set.code).first.bucket.to_i
          if qty.blank?
            decision true
            EodMailer.alert("LTR #{claim_set.code} reportable quantity is MISSING so reportable decision is #{decision}.").deliver_now
          else
            bot = statement_position.bot.to_i
            sld = statement_position.sld.to_i
            decision = (bot > qty or sld > qty) ? true : false
            Rails.logger.info "LTR #{claim_set.code} reportable quantity is #{qty} while bot/sld are #{bot}/#{sld} so reportable decision is #{decision}."
          end
        end
      rescue Exception => e
        EodMailer.alert("CME LTR build exception occurred. Skipping #{target}: #{e.message}.").deliver_now
      end

      decision
    end

    def got_parameters?
      report_type = ReportType.find_by_code 'LTR'
      (report_type.report_type_parameters.blank?) ? false : true
    end

    def get_claim_codes(date_one, date_two)
      claim_codes = StatementPosition.where("stated_on = ? or stated_on = ?", date_one, date_two).pluck(:claim_code)
      claim_codes.sort.uniq
    end

    def get_statement_positions(code, date)
      StatementPosition.stated_on(date).claim_code(code).select('stated_on, claim_code, sum(bot) as bot, sum(sld) as sld').group(:stated_on, :claim_code).order(:claim_code).first
    end

    def get_reportable_statement_position(today, prior)
      # if the prior was reportable then today is reportable
      if reportable?(prior) or reportable?(today)
        today
      else
        nil # nothing to report
      end
    end

    def get_statement_position_dummy(stated_on, claim_code)
      StatementPosition.new do |p|
        p.stated_on = stated_on
        p.claim_code = claim_code
        p.bot = 0
        p.sld = 0
      end
    end

    def add_line(statement_position)
      a, b = statement_position.claim_code.split(':')
      b = b.gsub(b[-3..-1], '')
      puts statement_position.claim_code, a, b

      net = statement_position.bot - statement_position.sld
      statement_position.sld = net < 0 ? net.abs : 0
      statement_position.bot = net > 0 ? net : 0

      #
      # THESE ARE CME SPECIFIC
      # CFTC CODES MAPPPED ELSEWHERE.
      #
      # A REFACTORING WOULD MAKE SENSE.
      #

      x = a.match('CBT') ? '01' : '02'
      i = a.match('CME') ? '353' : '330'

      date = statement_position.stated_on

      c = Claim.find_by_code(statement_position.claim_code)
      f = c.claimable

      "%2s%3s  %5s       %8s%2s %-5s%6s          %07d%07d%15s\n" % ['RP', i, '03000', date.strftime("%Y%m%d"), x, b, f.expires_on.strftime("%Y%m"), statement_position.bot, statement_position.sld, ' ']
    end
  end

end