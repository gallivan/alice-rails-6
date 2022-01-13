module Workers
  class PickerOfEodCme < Picker

    def build_report_eod_cme(root, kind, date, data)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      PickerReport.create! do |r|
        r.root = root
        r.kind = kind
        r.fate = 'TODO'
        r.data = data
        r.posted_on = date
      end
    end

    def pick(date)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      EodMailer.status('begun eod_cme_pick').deliver_now
      Rails.logger.info "Begun with #{date}"
      Rails.logger.info "Begun at #{Time.now}"
      picks = []
      date_str = date.strftime('%Y%m%d') if date.instance_of?(Date)
      filenames = ["FIXML-353_NYM_EOD-#{date_str}.xml", "FIXML-353_CME_EOD-#{date_str}.xml"]
      filenames.each do |filename|
        Rails.logger.info "Picking #{filename}"
        working_filename = setup_file(filename)
        read_lines(working_filename).each do |line|
          picks << build_report_eod_cme('EOD_CME', 'FILL', date, line)
        end
      end
      EodMailer.status('ended eod_cme_pick').deliver_now
      Rails.logger.info "Ended #{self.class}##{__method__} #{date}"
      picks
    end

    def setup_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info "setup_file #{filename}"

      local_filename = "#{ENV['DNL_DIR']}/cme/#{filename}"

      puts "local filename: #{local_filename}"

      if File.exist?(local_filename)
        puts "Using local copy #{local_filename}"
      elsif File.exist?(local_filename + '.zip')
        filename = local_filename + '.zip'
        puts "Using local zip #{filename}"
        ext_file(filename)
      else
        puts 'Using remote copy'
        rmt_filename = "#{filename}.zip"
        dnl_filename = get_file(rmt_filename)
        ext_file(dnl_filename)
      end
      local_filename
    end

    def ext_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info "Unzipping #{filename}"
      Dir.chdir "#{ENV['DNL_DIR']}/cme/"
      # TODO i need some error handling here - and elsewhere.
      Zip::ZipFile.open("#{filename}") do |cme_zip|
        cme_zip.each do |f|
          f_path = File.join("#{ENV['DNL_DIR']}/cme/", f.name)
          cme_zip.extract(f, f_path)
        end
      end
    end

    def read_lines(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      puts "Reading lines from #{filename}"
      lines = []
      File.open("#{filename}").each_line do |line|
        if line.match(TRDCAPT_REGEX)
          lines << prepare_line(line)
        end
      end
      lines
    end

    def get_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info "get_file: #{filename}"

      back = '167.204.41.33' # backup
      host = '164.74.122.33' # production

      username = ENV['SFTP_CME_USR']
      password = ENV['SFTP_CME_PWD']

      Rails.logger.info "Downloading #{filename}"

      dnl_filename = "#{ENV['DNL_DIR']}/cme/#{filename}"
      Rails.logger.info "Downloading to #{dnl_filename}"
      File.delete(dnl_filename) if File.exist?(dnl_filename)

      while true do
        begin
          Rails.logger.info "Net::SFTP try file: #{filename}"
          Net::SFTP.start(host, username, :password => password) do |sftp|
            sftp.download!("Outgoing/#{filename}", dnl_filename)
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

    def get_product_calendar_file
      Rails.logger.info "Calling #{self.class}##{__method__}"
      filename = 'product_calendar.xml'
      Rails.logger.info "get_file: #{filename}"

      host = 'ftp.cmegroup.com' # production

      Rails.logger.info "Downloading #{filename}"

      dnl_filename = "#{ENV['DNL_DIR']}/spn/#{filename}"
      Rails.logger.info "Downloading to #{dnl_filename}"
      File.delete(dnl_filename) if File.exist?(dnl_filename)

      while true do
        begin
          Rails.logger.info "Net::FTP try file: #{filename}"

          Net::FTP.open(host, username: 'anonymous', password: 'anonymous') do |ftp|
            ftp.passive = true
            ftp.chdir('/pub/span/util')
            ftp.getbinaryfile(filename, dnl_filename, 1024)
          end

          Rails.logger.info "Net::FTP got file: #{filename}"
          break
        rescue Exception => e
          message = "FTP exception occurred: #{e.message}. Sleeping until #{Time.now + FILE_WAIT_INTERVAL}."
          puts message
          Rails.logger.warn message
          # send_delay_email(message, FILE_WAIT_INTERVAL.from_now)
          sleep FILE_WAIT_INTERVAL
        end
      end

      dnl_filename
    end

  end
end