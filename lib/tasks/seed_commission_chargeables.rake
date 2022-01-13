task :seed_fee_chargeables => :environment do

  #claim_set_code	fee_chargeable_type_code	currency_code	amount	begun_on	ended_on
  #CBT:06	CLR	USD	0.06	2015-08-28	2018-08-28

  filename = "#{Rails.root}/etc/data/static/fee_chargeables.tab"
  puts filename

  if File.exist? filename
    File.open(filename).readlines.each do |line|
      next if line.match(/^claim/)
      puts line
      ary = line.split("\t")
      next unless ary.size > 2
      params = {
          fee_chargeable_type: FeeChargeableType.find_by_code(ary[1]),
          claim_set: ClaimSet.find_by_code(ary[0]),
          currency: Currency.find_by_code(ary[2]),
          amount: ary[3],
          begun_on: ary[4],
          ended_on: ary[5]
      }
      puts params.inspect
      FeeChargeable.create! params
    end
  else
    puts "#{filename} does not exist."
  end

end