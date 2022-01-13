task :foo, [:mee] => :environment do |t, args|
  puts t.name
  if args[:mee].blank?
    puts "Usage: rake foo[<greeting>]"
    puts "Usage: rake foo[hello]"
    exit
  end
  puts "#{args.mee} from #{t.name}"
  STDOUT.flush
  Rake::Task['bar'].invoke(args.mee)
end

task :bar, [:moo] => :environment do |t, args|
  puts " #{args.moo} from #{t.name}"
  STDOUT.flush
end