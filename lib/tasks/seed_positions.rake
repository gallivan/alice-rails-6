task :seed_positions, [:filename] => :environment do |t, args|

  unless args[:filename]
    puts "Positions filename missing?"
    puts "Usage: rake seed_positions[filename]"
    exit
  end

  filename = args[:filename]

  unless File.exists?(filename)
    puts "#{filename} does not exist. Exiting."
    exit
  end

  x = %W(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC)
  y = %W(F G H J K M N Q U V X Z)

  z = {}

  x.each_index { |i| z[x[i]] = y[i] }

  unless args[:filename]
    puts "Usage: rake seed_positions[filename]"
    exit
  end

  filename = args[:filename]

  unless File.exists?(filename)
    puts "#{filename} does not exist. Exiting."
    exit
  end

  puts "Building positions"

  exg = nil
  # claim = nil
  # account = nil
  claim_set = nil
  posting_date = nil

  File.open(filename).readlines.each do |line|
    # puts line

    if line.match(/^CREATED FOR/)
      ary = []
      ary << line[0..40].strip
      ary << line[41..120].strip
      ary << line[-20..-1].strip
      next unless ary[1].match(/-/)
      posting_date = Date.parse(ary[0])
      exg_code = ary[1].split(/-/)[0].strip
      exg = DealingVenue.find_by_code(exg_code)
    elsif line.match(/^.*{2}(USD|EUR|GBP|CHF|JPY|AUD|NZD)/) and not line.match(/(TOTAL|ORIGIN)/)
      ary = line.split(/\s+/)
      claim_set_code = "#{exg.code}:#{ary[2]}"
      claim_set = ClaimSet.find_by_code(claim_set_code)
    elsif line.match(/^\s{2}(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)/)
      puts '*' * 50
      puts line

      mth_code = line[2, 5]
      acc_code = line[52, 5]
      bot = line[57..70].to_i
      sld = line[73..82].to_i * -1
      prx = line[85..105].strip
      mth = mth_code[0..2]
      mth_code.gsub!(mth, z[mth])

      claim_code = "#{claim_set.code}#{mth_code}"

      claim = Claim.find_by_code(claim_code)
      account = Account.find_by_code(acc_code)

      done = bot > 0 ? bot : sld

      code = claim_set.code.split(':')[1]

      # puts prx
      # puts code
      # puts claim.code
      # puts claim_set.code

      # compute proper price

      if code.match('^(C|W|KW|S)$')
        head, tail = prx.split(/ /)
        if tail
          tail = eval(tail + '.0') / 100
        else
          tail = 0
        end
        prx = head.to_f + tail
      else
        prx = prx.to_f
      end

      prx = BigDecimal(prx, 8)

      # puts head
      # puts tail
      # puts prx

      puts "#{account.code} #{posting_date.strftime('%Y%m%d')} #{done} #{claim.code} #{prx}"

      report = "#{account.code} #{posting_date.strftime('%Y%m%d')} #{done} #{claim.code} #{prx}"
      norm = Workers::Normalizer.normalize_baseline_report(report)
      account.handle_fill(norm)
    end

  end

  puts 'done'
end

