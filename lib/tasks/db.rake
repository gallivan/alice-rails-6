namespace(:db) do

  task :dump, [:basename, :tag] => :environment do |t, args|
    basename = args[:basename]
    tag = args[:tag]
    if basename
      msg = "begun db dump #{basename} #{tag}"
      Rails.logger.info msg
      EodMailer.status(msg).deliver_now
      cmd = "pg_dump --verbose -Fc -f #{basename}_#{Date.today.strftime("%Y%m%d")}_#{tag}.pgr #{basename}"
      puts "Running: #{cmd}"
      system cmd
      msg = "ended db dump #{basename} #{tag}"
      Rails.logger.info msg
      EodMailer.status(msg).deliver_now
    else
      puts "Usage: rake db:dump[<db name>,<tag>]"
      puts "Usage: rake db:dump[alice_development,<post>]"
    end
  end

  task :dump_as_user, [:basename, :tag, :username] => :environment do |t, args|
    basename = args[:basename]
    username = args[:username]
    tag = args[:tag]
    if basename
      msg = "begun db dump #{basename} as user #{username}"
      Rails.logger.info msg
      EodMailer.status(msg).deliver_now
      cmd = "pg_dump --verbose -Fc -U #{username} -h localhost -f #{basename}_#{Date.today.strftime("%Y%m%d")}_#{tag}.pgr #{basename}"
      puts "Running: #{cmd}"
      system cmd
      msg = "ended db dump #{basename} as user #{username}"
      Rails.logger.info msg
      EodMailer.status(msg).deliver_now
    else
      puts "Usage: rake db:dump_as_user[<db name>,<tag>,<username>]"
      puts "Usage: rake db:dump_as_user[alice_development,post,alice]"
    end
  end

  task :restore, [:hostname, :basename, :username, :filename] do |t, args|
    username = args[:username]
    hostname = args[:hostname]
    basename = args[:basename]
    filename = args[:filename]
    if username and basename and filename
      puts username
      puts hostname
      puts basename
      puts filename
      cmd = "pg_restore --verbose --clean --no-acl --jobs=8 --no-owner -h #{hostname} -U #{username} -d #{basename} #{filename}"
      puts "Running: #{cmd}"
      system cmd
    else
      puts "Usage: rake db:restore[<host name>,<db name>,<user name>,<file name>]"
      puts "Usage: rake db:restore[localhost,alice_development,alice,/tmp/postgres_dump_file.pgr]"
    end
  end

  task :test_prep do |t|
    Rails.env = ENV['RAILS_ENV'] = 'test'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end

end