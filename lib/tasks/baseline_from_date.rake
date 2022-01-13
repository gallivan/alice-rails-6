task :baseline_from_date, [:date] => :environment do |t, args|
  begin
    date = Date.parse(args[:date])
  rescue Exception => e
    puts "Invalid argument: #{e}"
    puts "Usage: baseline_from_date['yyyy-mm-dd']"
    exit
  end

  puts "Baseline from #{date}"
  puts "*" * 50
  puts "DATE USE NOW HARD CODED TO JUNE 2016"
  puts "*" * 50

  print "Clearing dynamic data..."
  Rake::Task["clear_dynamic_data"].invoke
  puts 'done'
end