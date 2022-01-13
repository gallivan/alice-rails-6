task :cme_eod_file_stats, [:filename] => :environment do |t, args|
  if args[:filename].blank?
    puts "Usage: cme_eod_file_stats['cme_eod_filename']"
    exit
  end

  file = File.open(args[:filename])

  stats = {}

  file.each_line do |line|
    if line.match(TRDCAPT_REGEX)
      line = Picker.prepare_line(line)
      hash = Packer.cme_fixml_to_hash(line)

      desc = hash['FIXML']['TrdCaptRpt']['Instrmt']['Desc']
      exch = hash['FIXML']['TrdCaptRpt']['Instrmt']['Exch']
      code = hash['FIXML']['TrdCaptRpt']['Instrmt']['ID']
      acct = hash['FIXML']['TrdCaptRpt']['RptSide']['Pty'][4]['ID']
      date = hash['FIXML']['TrdCaptRpt']['Instrmt']['MatDt']
      name = exch + ':' + desc + ':' + code

      unless stats.has_key?(name)
        puts name
        stats[name] = {
            counts: 0,
            accounts: Set.new,
            maturities: Set.new
        }
      end

      stats[name][:counts] += 1
      stats[name][:accounts].add(acct)
      stats[name][:maturities].add(date)
    end
  end

  stats.keys.sort.each do |name|
    puts '*' * 20
    puts " #{name}"
    puts stats[name][:counts]
    stats[name][:accounts].sort.each{|e| print " #{e}"}; puts
    stats[name][:maturities].sort.each{|e| print " #{e}"}; puts
  end
end