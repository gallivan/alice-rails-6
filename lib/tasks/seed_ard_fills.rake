def find_claim(line)
  Builders::ClaimBuilder.build_from_ard(line)
end

def find_fill_params(claim, line)
  #               131            3.73                                       00002                           0 0     MANUAL                         -16,375.00 MANL
  #     131                      3.73                                       00708                           0 0     MANUAL                          16,375.00 MANL
  #       2                     97.9200    3E3L                             00022      2                    0 0 EOD ELEC REG  DIFSP                    325.00 EXCH
  #                25           97.9200    3E3L                             00022      2                    0 0 EOD ELEC REG  DIFSP                 -4,062.50 EXCH

  bot = line.slice(0..8).strip
  sld = line.slice(9..18).strip
  trd = line.slice(19..39).strip
  acc = line.slice(73..78).strip


  if claim.code.match('^CBT:(C|W|KW|S|17|21|25|26|UBE)')
    # puts '*' * 100
    puts line
    head, tail = trd.split(/ /)
    puts "#{trd}|#{head}|#{tail}"
    if claim.code.match('^CBT:(C|W|KW|S)')
      head = head.to_f * 100
    else
      head = head.to_f
    end
    puts "#{trd}|#{head}|#{tail}"

    tail = (tail.blank?) ? 0 : eval(tail << '.0')

    prx = head + tail
    prx = BigDecimal(prx, 16)
  else
    prx = BigDecimal(trd, 16)
  end

  puts "[#{bot}|#{sld}|#{prx}|#{trd}|#{acc}]"

  if bot.blank?
    amt = sld.to_i * -1
  else
    amt = bot.to_i
  end

  prng = Random.new
  dealing_venue_code = claim.code.split(/:/)
  dealing_venue = DealingVenue.find_by_code(dealing_venue_code)

  {
      account_id: Account.find_by_code(acc).id,
      claim_id: claim.id,
      done: amt,
      price: prx,
      price_traded: trd,
      system_id: System.find_by_code('BKO').id,
      dealing_venue_id: dealing_venue.id,
      dealing_venue_done_id: "BKO-#{prng.rand(1_000_000_000..9_999_999_999)} #{Time.now.to_i}"
  }
end

task :seed_ard_fills, [:filename] => :environment do |t, args|
  unless args[:filename]
    puts "ARD trade register missing?"
    puts "Usage: rake seed_ard_fills[filename]"
    exit
  end

  filename = args[:filename]

  unless File.exist?(filename)
    puts "#{filename} does not exist. Exiting."
    exit
  end

  lines = File.readlines(filename)

  claim = nil
  traded_on = nil

  booker = Workers::BookerOfArd.new

  lines.each do |line|
    line.chomp!
    if line.match(/SETTLEMENT PRICE/)
      claim = find_claim(line)
    elsif line.match(/TRADE DATE/)
      traded_on = Date.parse(line.split(/: /)[1])
    end
    if claim
      next unless claim.code.match(/^(CME|CBT|NYMEX)/)
      if line.match(/(EOD ELEC REG|PIT  REG)/)
        puts "#{claim.code} #{traded_on}"
        params = find_fill_params(claim, line).merge(posted_on: traded_on, traded_on: traded_on, traded_at: traded_on)
        booker.book(params)
      end
    end
  end

end