namespace :play do

  task :simple => :environment do |t|
    puts "task name: #{t.name}"
    STDOUT.flush
    count = 0
    loop do
      count += 1
      puts "Hello from rake task #{t.name} on loop #{count}"
      STDOUT.flush
      sleep 1
    end
  end

  task :normal => :environment do |t|
    puts "task name: #{t.name}"
    puts "All good."
    exit 0
  end

  task :exception => :environment do |t|
    puts "task name: #{t.name}"
    raise "I cannot rescue an exception."
  end

  task :rescue_exception => :environment do |t|
    puts "task name: #{t.name}"
    begin
      raise "I can rescue an exception."
    rescue Exception => e
      puts "Exception rescued: #{e}"
      exit 1
    end
    exit 0
  end

end