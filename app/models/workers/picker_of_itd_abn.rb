module Workers
  class PickerOfItdAbn < Picker

    def initialize
      @all = build_connection('itd.abn.picked.all')
      # @evn = build_connection('eod.cme.picked.evn')
      # @odd = build_connection('eod.cme.picked.odd')
    end

    def build_connection(destination)
      conn = Bunny.new(:user => "alice", :password => ENV['ALICE_RABBITMQ_PWD'])
      conn.start

      c = conn.create_channel
      q = c.queue(destination, :durable => true, :auto_delete => false)
      x = c.fanout(destination, :durable => true)

      q.bind(x)

      [x, q]
    end

    def build_report_itd_abn(root, kind, date, data)
      PickerReport.create! do |r|
        r.root = root
        r.kind = kind
        r.fate = 'TODO'
        r.data = data
        r.posted_on = date
      end
    end

    def load_file(filename, date, date_str)
      lines = read_lines(filename)
      lines.shift # drop the header line
      lines.each do |line|
        line = [line, date_str].join(',')
        report = build_report_itd_abn('ITD_ABN', 'FILL', date, line)
        send_report(report)
      end
    end

    def pick(date)
      date = Date.parse(date) unless date.instance_of?(Date)
      date_str = date.strftime('%Y%m%d')
      filename = "Intraday6_MICS_#{date_str}.csv"
      Rails.logger.info "Picking #{filename}"
      working_filename = setup_file(filename)
      load_file(working_filename, date, date_str) if not working_filename.blank? and File.exist? working_filename
    end

    def resend_report(report)
      send_report(report)
    end

    def send_report(report)
      begin
        puts "PickerReport: #{report.id}"
        Rails.logger.info("Picker: TODO handling PickerReport #{report.id}")
        send_message(@all, report.data)
        report.update_attribute(:fate, 'DONE')
        Rails.logger.info("Picker: DONE handling PickerReport #{report.id}")
      rescue Exception => e
        msg - "Picker: FAIL handling PickerReport #{report.id}"
        Rails.logger.info(msg)
        EodMailer.alert(msg).deliver_now
        report.update_attributes(fate: 'FAIL', goof_error: e.message, goof_trace: e.backtrace)
      end
    end

    def send_message(destination, message)
      x, q = destination
      x.publish(message, :routing_key => q.name)
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
      Rails.logger.info "setup_file: remote #{filename}"

      local_filename = "#{ENV['DNL_DIR']}/abn/#{filename}"

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
      Rails.logger.info "get_file sftp remote: #{filename}"

      host = 'sftp.us.abnamroclearing.com' # production
      back = 'sftp2.us.abnamroclearing.com' # backup

      username = ENV['SFTP_ABN_USR']
      password = ENV['SFTP_ABN_PWD']

      Rails.logger.info "Downloading #{filename}"

      dnl_filename = "#{ENV['DNL_DIR']}/abn/#{filename}"
      Rails.logger.info "Downloading #{filename} to #{dnl_filename}"
      File.delete(dnl_filename) if File.exist?(dnl_filename)

      # http://net-ssh.github.io/ssh/v1/chapter-2.html
      # http://stackoverflow.com/questions/869589/why-ssh-fails-from-crontab-but-succedes-when-executed-from-a-command-line
      # sudo apt-get install keychain

      while true do
        begin
          Rails.logger.info "Net::SFTP try file: #{filename}"

          if RuntimeSwitch.is_on?(:load_abn_activity)
            # want to download
            # Net::SFTP.start(host, username, password: password, host_key: 'ssh-dss') do |sftp|
            Net::SFTP.start(host, username, host_key: 'ssh-rsa') do |sftp|
              Rails.logger.info "Net::SFTP attached"
              sftp.download!(filename, dnl_filename)
            end
            Rails.logger.info "Net::SFTP got file: #{filename}"
            break
          else
            # do not want to download
            dnl_filename = nil
            break
          end

        rescue Exception => e
          msg = "SFTP exception occurred: #{e.message}. Sleeping until #{Time.now + FILE_WAIT_INTERVAL}."
          EodMailer.alert(msg).deliver_now

          # avoid having to pay attention to this.
          # client risk desk was to have done this.
          # that never happened. low cost change.
          sleep 5
          EodMailer.alert('Setting load_abn_activity to false.').deliver_now
          RuntimeSwitch.set_off(:load_abn_activity)

          sleep FILE_WAIT_INTERVAL
        end
      end

      dnl_filename
    end

  end
end

