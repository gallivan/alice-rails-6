def get_claim_code(claim_set, mth_code)
  y, t = mth_code.split('-')
  x = {'Mar': 'H', 'Jun': 'M', 'Sep': 'U', 'Dec': 'Z'}
  m = x[t.to_sym]
  "#{claim_set.code}#{m}#{y}"
end

def account_alias_to_code(key)
  map = {
    'LEMMS1' => '00005',
    'LEMMS2' => '00022',
    'LEMMS3' => '00071',
    'LEMMS4' => '00077',
    'LEMMS5' => '00013',
    'LEMMS6' => '00333',
    'LEMMS7' => '00455',
    'LEMMS8' => '00624',
    'LEMMS9' => '00877',
    'LEMMS10' => '00902',
    'LEMMS11' => '02005',
    'LEMMS12' => '02010',
    'LEMMS13' => '01846',
    'LEMMS14' => '05520',
    'LEMMS15' => '55555',
    'LEMMS16' => '06969',
    'LEMMS17' => '88888',
    'LEMMS18' => '39009',
  }
  map[key]
end

def book_fill(line)
  if line !~ /Client Area/
    puts line
    tokens = line.split('|')

    ActiveRecord::Base.transaction do
      dealing_venue_code = tokens[0]
      dealing_venue = DealingVenue.find_by_code dealing_venue_code
      if dealing_venue.blank?
        puts "Exiting. Could not map DealingVenue #{dealing_venue_code}"
        exit
      end

      account_code = account_alias_to_code(tokens[20])
      account = Account.find_by_code account_code
      if account.blank?
        puts "Exiting. Could not map Account #{account_code}"
        exit
      end

      claim_set_code = "#{dealing_venue_code}:#{tokens[7]}"
      claim_set = ClaimSet.find_by_code claim_set_code
      if claim_set.blank?
        puts "Exiting. Could not map ClaimSet #{claim_set_code}"
        exit
      end

      mth_code = tokens[8]
      claim_code = get_claim_code(claim_set, mth_code)
      claim = Claim.find_by_code claim_code
      if claim.blank?
        puts "Exiting. Could not map Claim #{claim_code}"
        exit
      end

      done = tokens[9] == 'Buy' ? tokens[11].to_i : tokens[11].to_i * -1
      price = BigDecimal(tokens[10], 8)
      price_traded = price
      timestamp = DateTime.parse(tokens[6])
      traded_on = timestamp.to_date
      traded_at = timestamp.to_time
      posted_on = traded_on
      dealing_venue_done_id = tokens[43]
      booker_report_id = tokens[46]
      puts tokens[6]
      puts posted_on
      puts traded_on
      puts traded_at

      fill = DealLegFill.new do |f|
        f.kind = 'DATA'
        f.dealing_venue = dealing_venue
        f.account = account
        f.system = System.find_by_code('BKO')
        f.claim = claim
        f.done = done
        f.price = price
        f.price_traded = price_traded
        f.posted_on = posted_on
        f.traded_on = traded_on
        f.traded_at = traded_at
        f.dealing_venue_done_id = dealing_venue_done_id
        f.booker_report_id = booker_report_id
      end
      puts fill.attributes

      position = Builders::PositionBuilder.build_or_update(fill)
      fill.update(position_id: position.id)
      fill.save!
    end
  end
end

task :ghf_seals_trade_loader, [:filename] => :environment do |t, args|
  puts t.name
  if args[:filename].blank?
    puts "Usage: rake ghf_seals_trade_loader[<filename>]"
    exit
  end
  STDOUT.flush
  if not File.exists? args.filename
    puts "Exiting. Missing input file: #{args.filename}"
    exit
  end
  puts "Running with #{args.filename}"
  File.readlines(args.filename).each do |line|
    book_fill(line)
  end
end
