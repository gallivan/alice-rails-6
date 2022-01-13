require 'net/sftp'

namespace :test_mics_sftp do
  hostname = 'sftp.us.abnamroclearing.com'
  username = ENV['SFTP_ABN_USR']
  password = ENV['SFTP_ABN_PWD']

  task :dir => :environment do |t|
    src_path = '/'
    Net::SFTP.start(hostname, username, password: password) do |sftp|
      sftp.dir.foreach(src_path) { |entry| puts entry.longname }
    end
  end

  task :itd, [:date] => :environment do |t, args|
    if args[:date].blank?
      puts "Usage: test_mics_sftp:itd[YYYYMMDD]"
      puts "Usage: test_mics_sftp:itd[20191122]"
      exit
    else
      filename = "Intraday6_MICS_#{args[:date]}.csv"
      src_path = filename
      dnl_path = "/tmp/#{filename}"
    end

    Net::SFTP.start(hostname, username, password: password) do |sftp|
      puts "download #{src_path} from the remote #{hostname} to #{dnl_path}"
      sftp.download!(src_path, dnl_path) do |event, downloader, *args|
        case event
        when :open then
          # args[0] : file metadata
          puts "starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes}"
        when :get then
          # args[0] : file metadata
          # args[1] : byte offset in remote file
          # args[2] : data that was received
          puts "writing #{args[2].length} bytes to #{args[0].local} starting at #{args[1]}"
        when :close then
          # args[0] : file metadata
          puts "finished with #{args[0].remote}"
        when :mkdir then
          # args[0] : local path name
          puts "creating directory #{args[0]}"
        when :finish then
          puts "all done!"
        end
      end
    end
  end

  task :all => :environment do |t|
    src_path = '/'
    trg_path = '/tmp/mics'
    Net::SFTP.start(hostname, username, password: password) do |sftp|
      puts "download #{src_path} from the remote #{hostname} to #{trg_path}"
      sftp.download!(src_path, trg_path, :recursive => true) do |event, downloader, *args|
        case event
        when :open then
          # args[0] : file metadata
          puts "starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes}"
        when :get then
          # args[0] : file metadata
          # args[1] : byte offset in remote file
          # args[2] : data that was received
          puts "writing #{args[2].length} bytes to #{args[0].local} starting at #{args[1]}"
        when :close then
          # args[0] : file metadata
          puts "finished with #{args[0].remote}"
        when :mkdir then
          # args[0] : local path name
          puts "creating directory #{args[0]}"
        when :finish then
          puts "all done!"
        end
      end
    end
  end

end

