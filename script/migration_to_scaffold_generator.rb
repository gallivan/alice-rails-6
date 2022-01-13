
def usage
  puts "Usage: $0 <migration_file>"
  exit
end

usage unless ARGV.length == 1

puts "Working with #{ARGV[0]}"

out = 'rails generate scaffold '

File.open(ARGV[0]).each_line do |line|
  line.strip!
  if line =~ /^class/
    out << line.split(' ')[1].chop.gsub('Create','')
  end
  if line =~ /^t\./
    next if line =~ /timestamps/
    puts line
    type, name = line.split ' '

    type = type.gsub('t.','')
    name = name.gsub(',', '').gsub(':','')
    puts type
    puts name
    out << " #{name}:#{type}"
  end
end

out << ' --skip'

puts out