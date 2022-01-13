module Workers
  class LargeTraderReportCme < LargeTraderReport

    def report(date)
      # http://www.cmegroup.com/tools-information/lookups/advisories/market-regulation/CMEGroup_RA1003-5.html#pageNumber=1

      # The deadline for daily FTP submission of the Large Trader position
      # file is 7:00 a.m. Central Time (“CT”), (8:00 a.m. Eastern Time (“ET”)
      # for CBOT, CME, NYMEX and COMEX products, and 11:00 p.m. CT (12:00 a.m. ET)
      # for DME products.  Error corrections or any other adjustments to the
      # Large Trader position file must be completed by 8:00 a.m. CT (9:00 a.m. ET),
      # and these adjustments must be made using the web-based Large Trader
      # Reportable Position (“LTRP”) application, accessed at http://connect.cme.com.

      # http://www.cftc.gov/industryoversight/marketsurveillance/ltrformat
      # PFTP.F353RPS.20161229.DATA

      EodMailer.status("begun LargeTraderReportCme build").deliver_now

      if not got_parameters?
        msg = "LargeTraderReportCme found no ReportTypeParameters for ReportType LTR. Skipping."
        EodMailer.alert(msg).deliver_now
        return
      end

      begin
        lines = compute(date)

        filename = "#{ENV['LRG_DIR']}/PFTP.F353RPS.#{date.strftime('%Y%m%d')}.DATA"
        File.unlink(filename) if File.exist?(filename)

        file = File.open(filename, 'w')
        lines.each { |line| file.write(line) }
        file.close

        memo = "CME Large Trader Report for #{date}"

        reports = Report.where('memo = ?', memo)
        reports.each { |report| report.delete } unless reports.blank?

        report_type = ReportType.where(code: 'LTR-CME').first_or_create(code: 'LTR-CME', name: 'CME Large Trader Report')
        format_type = FormatType.where(code: 'TXT').first_or_create(code: 'TXT', name: 'TXT')

        Report.create! do |r|
          r.report_type = report_type
          r.format_type = format_type
          r.posted_on = date
          r.memo = memo
          r.location = filename
        end
      rescue Exception => e
        msg = "CME LTR NOT SENT. Exception occurred: #{e.message}."
        EodMailer.alert(msg).deliver_now
      end

      if Rails.env.production?
        if RuntimeSwitch.is_on?(:send_large_trader_report_to_cme)
          distribute(filename)
          msg = "CME LTR SENT from environment #{Rails.env}."
          EodMailer.alert(msg).deliver_now
        else
          msg = "RuntimeSwitch send_large_trader_report_to_cme is OFF."
          EodMailer.alert(msg).deliver_now
        end
      else
        msg = "CME LTR NOT SENT from environment #{Rails.env}."
        EodMailer.alert(msg).deliver_now
      end
      EodMailer.status("ended LargeTraderReportCme build").deliver_now
    end

    def distribute(filename)
      host = RuntimeKnob.code_for_name('cme_host_name') || '164.74.122.33'
      user = RuntimeKnob.code_for_name('cme_host_user') || ENV['SFTP_CME_USR']
      pass = RuntimeKnob.code_for_name('cme_host_pass') || ENV['SFTP_CME_PWD']

      if host.blank? or user.blank? or pass.blank?
        msg = "CME LTR not sent: "
        # can clearly do better....
        EodMailer.alert(msg + "host blank.").delier_now if host.blank?
        EodMailer.alert(msg + "user blank.").delier_now if user.blank?
        EodMailer.alert(msg + "pass blank.").delier_now if pass.blank?
      else
        Net::SFTP.start(host, user, :password => pass) do |sftp|
          begin
            Rails.logger.info "Begun sending #{filename} to the CME."
            Net::SFTP.start(host, user, :password => pass) do |sftp|
              sftp.upload(filename, "Incoming/#{File.basename(filename)}")
            end
            Rails.logger.info "Ended sending #{filename} to the CME."
          rescue Exception => e
            msg = "CME LTR NOT SENT. SFTP exception occurred: #{e.message}."
            EodMailer.alert(msg).deliver_now
          end
        end
      end
    end

  end
end