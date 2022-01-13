module Workers
  class LargeTraderReportCftc < LargeTraderReport

    def report(date)
      EodMailer.status("begun LargeTraderReportCftc build").deliver_now

      if not got_parameters?
        EodMailer.alert("LargeTraderReportCftc found no ReportTypeParameters for ReportType LTR. Skipping.").deliver_now
        return
      end

      begin
        lines = compute(date)

        # cftcpos.txt
        filename = "#{ENV['LRG_DIR']}/cftcpos.txt.#{date.strftime('%Y%m%d')}"
        File.unlink(filename) if File.exist?(filename)

        file = File.open(filename, 'w')
        lines.each do |line|
          line = line.gsub('RP353', 'RPAGF').gsub('RP330', 'RPAGF')
          file.write(line)
        end
        file.close

        memo = "CFTC Large Trader Report for #{date}"

        reports = Report.where('memo = ?', memo)
        reports.each {|report| report.delete} unless reports.blank?

        report_type = ReportType.where(code: 'LTR-CFTC').first_or_create(code: 'LTR-CFTC', name: 'CFTC Large Trader Report')
        format_type = FormatType.where(code: 'TXT').first_or_create(code: 'TXT', name: 'TXT')

        Report.create! do |r|
          r.report_type = report_type
          r.format_type = format_type
          r.posted_on = date
          r.memo = memo
          r.location = filename
        end

      rescue Exception => e
        msg = "CFTC LTR NOT SENT. Exception occurred: #{e.message}."
        EodMailer.alert(msg).deliver_now
      end

      if Rails.env.production?
        if RuntimeSwitch.is_on?(:send_large_trader_report_to_cftc)
          distribute(filename)
          msg = "CFTC LTR SENT from environment #{Rails.env}."
          EodMailer.alert(msg).deliver_now
        else
          msg = "RuntimeSwitch send_large_trader_report_to_cftc is OFF."
          EodMailer.alert(msg).deliver_now
        end
      else
        msg = "CFTC LTR NOT SENT from environment #{Rails.env}."
        EodMailer.alert(msg).deliver_now
      end

      EodMailer.status("ended LargeTraderReportCftc build").deliver_now
    end

    def distribute(filename)
      begin
        host = RuntimeKnob.code_for_name('cftc_host_name') || 'traders.cftc.gov'
        user = RuntimeKnob.code_for_name('cftc_host_user') || ENV['SFTP_CFTC_USR']
        pass = RuntimeKnob.code_for_name('cftc_host_pass') || ENV['SFTP_CFTC_PWD']

        if host.blank? or user.blank? or pass.blank?
          msg = "CFTC LTR not sent: "
          # can clearly do better....
          EodMailer.alert(msg + "host blank.").deliver_now if host.blank?
          EodMailer.alert(msg + "user blank.").deliver_now if user.blank?
          EodMailer.alert(msg + "pass blank.").deliver_now if pass.blank?
        else
          Rails.logger.info "Begun sending #{filename} to the CFTC."
          begin
            # Instance SSH/SFTP session :
            session = Net::SSH.start(host, user, password: pass, verbose: :debug, timeout: 120)
            sftp = Net::SFTP::Session.new(session)
            sftp.connect! # Establish connection
            sftp.upload!(filename, 'cftcpos.txt')
            sftp.close!(session)
            sftp.session.shutdown!
            session.close unless session.nil?
          rescue IOError => e
            msg = "Normal, given session management. SFTP exception occurred: #{e.message}."
            EodMailer.alert(msg).deliver_now
            Rails.logger.warn "Ended sending #{filename} to the CFTC."
          rescue Timeout::Error
            msg = "Timeout. Things likey worked."
            EodMailer.alert(msg).deliver_now
          rescue Exception => e
            msg = "CFTC LTR NOT SENT. SFTP exception occurred: #{e.message}."
            EodMailer.alert(msg).deliver_now
          end
          Rails.logger.info "Ended sending #{filename} to the CFTC."

        end
      end
    end

  end
end