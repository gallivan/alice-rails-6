
desc "Create claim_sets.tab, claims.tab and chargeables.tab in etc/data/static called by seeds.rb"
task :extract_static_data => :environment do

  # ClaimSet

  name = "#{Rails.root}/etc/data/static/claim_sets.tab"
  puts "Begun #{name}"
  File.unlink(name) if File.exists?(name)
  file = File.open(name, "w")
  ClaimSet.order(:code).each do |claim_set|
    line = []
    line << claim_set.code
    line << claim_set.name
    file.write(line.join("\t") + "\n")
  end
  file.close
  puts "Ended #{name}"

  # Claim

  name = "#{Rails.root}/etc/data/static/claims.tab"
  puts "Begun #{name}"
  File.unlink(name) if File.exists?(name)
  file = File.open(name, "w")
  Claim.order(:code).each do |claim|
    line = []
    line << claim.claim_set.code
    line << claim.claim_type.code
    line << claim.entity.code
    line << claim.code
    line << claim.name
    line << claim.size
    line << claim.point_value
    line << claim.point_currency.code
    line << claim.claimable.code
    line << claim.claimable.expires_on
    file.write(line.join("\t") + "\n")
  end
  file.close
  puts "Ended #{name}"

  # Chargeable

  name = "#{Rails.root}/etc/data/static/chargeables.tab"
  puts "Begun #{name}"
  File.unlink(name) if File.exists?(name)
  file = File.open(name, "w")
  Chargeable.order(:id).each do |chargeable|
    line = []
    line << chargeable.claim_set.code
    line << chargeable.chargeable_type.code
    line << chargeable.currency.code
    line << chargeable.amount
    line << chargeable.begun_on
    line << chargeable.ended_on
    file.write(line.join("\t") + "\n")
  end
  file.close
  puts "Ended #{name}"

end

