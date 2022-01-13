task :panic_eod_extract, [:source, :filename] => :environment do |t, args|
  if args[:source].blank? or args[:filename].blank? or args[:source] !~ /ABN|CME/
    puts "Usage: rake panic_eod_extract[ABN,/path/to/abn/file.csv]"
    puts "Usage: rake panic_eod_extract[CME,/path/to/cme/file.xml]"
    exit
  end

  extract_abn(args[:filename]) if args[:source] =~ /ABN/
  extract_cme(args[:filename]) if args[:source] =~ /CME/
end

def extract_abn(filename)
  if File.exists? filename
    File.open(filename).each do |line|
      next if line =~ /^FIRM/
      next if line =~ /^.{2}Trailer/
      out = []
      elements = line.split(',')
      elements[20] = elements[20].match(/1/) ? 'BOT' : 'SLD'
      [2, 18, 20, 79, 80, 49, 19, 87].each {|i| out << elements[i]}
      puts '*' * 10
      puts out.join(',')
    end
  else
    puts "File #{filename} does not exist. Exiting."
    exit
  end
end

def extract_cme(filename)

end