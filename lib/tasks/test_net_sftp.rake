require 'net/sftp'

def test_file_create(filename)
  File.open(filename, 'w') {|file| file.write("hello world!")}
end

def test_file_delete(filename)
  File.unlink(filename)
end

namespace :ftp do
  task :test, [:hostname, :username, :password] => :environment do |t, args|

    if args[:hostname].blank? or args[:username].blank? or args[:password].blank?
      puts "Usage #{t}[hostname,username,password]"
      exit
    end

    hostname = args[:hostname]
    username = args[:username]
    password = args[:password]

    filename = '/tmp/hello-world.txt'
    test_file_create(filename)

    Net::SFTP.start(hostname, username, password: password) do |sftp|
      puts "upload #{filename} to the remote #{hostname}"
      sftp.upload!(filename, filename)

      puts "delete local file #{filename}"
      test_file_delete(filename)

      puts "download #{filename} from the remote #{hostname}"
      sftp.download!(filename, filename)

      puts "downloaded file exists? #{File.exist?(filename)}"

      # # grab data off the remote host directly to a buffer
      # data = sftp.download!("/path/to/remote")
      #
      # # open and write to a pseudo-IO for a remote file
      # sftp.file.open("/path/to/remote", "w") do |f|
      #   f.puts "Hello, world!\n"
      # end
      #
      # # open and read from a pseudo-IO for a remote file
      # sftp.file.open("/path/to/remote", "r") do |f|
      #   puts f.gets
      # end
      #
      # # create a directory
      # sftp.mkdir! "/path/to/directory"
      #
      # # list the entries in a directory
      # sftp.dir.foreach("/path/to/directory") do |entry|
      #   puts entry.longname
      # end

      test_file_delete(filename)
    end

  end
end

