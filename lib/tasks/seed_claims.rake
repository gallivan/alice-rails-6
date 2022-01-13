task :seed_claims => :environment do

  #claim_set_code	claim_type_code	entity_code	claim_code	claim_name	claim_size	claim_point_value	point_currency_code	future_code	future_expires_on
  #CBT:06	FUT	CBT	CBT:06F17	CBT:SOYBEAN MEAL FUTURES Jan 2017	100.0	100.0	USD	CBT:06F17	2017-01-13

  filename = "#{Rails.root}/etc/data/static/claims.tab"
  puts filename

  if File.exist? filename
    File.open(filename).readlines.each do |line|
      next if line.match(/^claim/)
      puts line
      ary = line.split("\t")
      next unless ary.size > 2
      params = {
          code: ary[3],
          expires_on: ary[-1]
      }
      puts params.inspect
      future = Future.create! params
      params = {
          claim_set: ClaimSet.find_by_code(ary[0]),
          claim_type: ClaimType.find_by_code(ary[1]),
          entity: Entity.find_by_code(ary[2]),
          code: ary[3],
          name: ary[4],
          size: ary[5],
          point_value: ary[6],
          point_currency: Currency.find_by_code(ary[7]),
          claimable: future
      }
      puts params.inspect
      Claim.create! params
    end
  else
    puts "#{filename} does not exist."
  end

end