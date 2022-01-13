task :cftc_test => :environment do
  require 'net/ftp'
  require 'net/sftp'
  ftp = Net::FTP.new
  ftp.connect('traders.cftc.gov', 21)
  ftp.login('trader', '0x8A8714AA')
  # ftp.chdir("/var/tmp")
  # ftp.puttextfile(file_name)
end