module Workers
  class PickerOfEodGhf < Picker

    def build_report_eod_ghf(root, kind, date, data)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      PickerReport.create! do |r|
        r.root = root
        r.kind = kind
        r.fate = 'TODO'
        r.data = data
        r.posted_on = date
      end
    end

    def load_file(filename, date, date_str)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      reports = []
      lines = read_lines(filename)
      lines.shift # drop the header line
      lines.each do |line|
        next unless line =~ /^NT/ # only new trade lines
        line = [line, date_str].join(',')
        reports << build_report_eod_ghf('EOD_GHF', 'FILL', date, line)
      end
      reports
    end

    def pick(date)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info "Calling #{self.class}##{__method__}"
      EodMailer.status('begun eod_ghf_pick').deliver_now
      Rails.logger.info "Begun with #{date}"
      Rails.logger.info "Begun at #{Time.now}"

      # MIR13_LON_EMMGRP_16082021.csv
      date_str = date.strftime('%d%m%Y')
      filename = "MIR13_LON_EMMGRP_#{date_str}.csv"
      Rails.logger.info "Picking #{filename}"
      working_filename = setup_file(filename)
      picker_reports = load_file(working_filename, date, date_str) if not working_filename.blank? and File.exist? working_filename

      Rails.logger.info "Ended with #{date}"
      Rails.logger.info "Ended at #{Time.now}"
      EodMailer.status('ended eod_ghf_pick').deliver_now
      picker_reports
    end

    def read_lines(filename)
      Rails.logger.info "Reading lines from #{filename}"
      lines = []
      File.open("#{filename}").each_line do |line|
        lines << line
      end
      lines
    end

    def setup_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info "setup_file: remote #{filename}"

      local_filename = "#{ENV['DNL_DIR']}/ghf/#{filename}"

      Rails.logger.info "local filename: #{local_filename}"

      if File.exist?(local_filename)
        Rails.logger.info "Using local copy #{local_filename}"
      else
        Rails.logger.info "Using remote copy #{filename}"
        local_filename = get_file(filename)
      end
      local_filename
    end

    def get_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info "get_file sftp remote: #{filename}"

      # host = 'ftp.ghfinancials.com' # production
      host = 'sftp.ghfinancials.com' # production

      username = ENV['SFTP_GHF_USR']

      password = ENV['SFTP_GHF_PWD']

      Rails.logger.info "Downloading #{filename}"

      dnl_filename = "#{ENV['DNL_DIR']}/ghf/#{filename}"
      Rails.logger.info "Downloading #{filename} to #{dnl_filename}"
      File.delete(dnl_filename) if File.exist?(dnl_filename)

      # http://net-ssh.github.io/ssh/v1/chapter-2.html
      # http://stackoverflow.com/questions/869589/why-ssh-fails-from-crontab-but-succedes-when-executed-from-a-command-line
      # sudo apt-get install keychain

      while true do
        begin
          Rails.logger.info "Net::SFTP try file: #{filename}"

          if RuntimeSwitch.is_on?(:load_ghf_activity)
            # want to download
            # Net::SFTP.start(host, username, { password: password, non_interactive: true, keys: '~/.ssh/ghfincial_sftp_private_key', append_all_supported_algorithms: true }) do |sftp|
            Net::SFTP.start(host, username, {keys_only: true, keys: '~/.ssh/ghfincial_sftp_private_key', append_all_supported_algorithms: true}) do |sftp|
              Rails.logger.info "Net::SFTP attached"
              sftp.download!("Eagle.Market.Makers/#{filename}", dnl_filename)
            end
            Rails.logger.info "Net::SFTP got file: #{filename}"
            break
          else
            # do not want to download
            Rails.logger.warn "RuntimeSwitch :load_ghf_activity is off. Skipping SFTP of #{filename}"
            dnl_filename = nil
            break
          end

        rescue Exception => e
          msg = "SFTP exception occurred: #{e.message}. Sleeping until #{Time.now + FILE_WAIT_INTERVAL}."
          EodMailer.alert(msg).deliver_now
          puts e.message
          Rails.logger.warn e.message
          sleep FILE_WAIT_INTERVAL
        end
      end

      dnl_filename
    end

  end
end

