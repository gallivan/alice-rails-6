task :seed_abn_baseline_positions, [:filename] => :environment do |t, args|
  unless args[:filename]
    puts "ABN position filename missing?"
    puts "Usage: rake seed_abn_baseline_positions[filename]"
    exit
  end

  filename = args[:filename]

  puts "Baselining positions...."

  unless File.exist?(filename)
    puts "#{filename} does not exist. Exiting."
    exit
  end

  lines = File.readlines(filename)

  posting_date = Date.parse(lines[-1].split(',')[1])

  lines.each do |line|
    next unless line.match(/^T/)
    puts line
    norm = Workers::Normalizer.normalize_abn_pos_csv(line, posting_date)
    puts '*' * 20
    puts norm.inspect
    account = Account.find(norm[:account_id])
    account.handle_fill(norm)
  end

  puts 'done'
end