task :collapse_exg_clr_to_exg => :environment do
  ClaimSet.all.each do |claim_set|
    puts claim_set.code
    exg = claim_set.chargeables.exchange.first
    clr = claim_set.chargeables.clearing.first
    if clr and exg
      puts 'got both'
      if clr.currency != exg.currency
        puts 'break ' * 20
        puts claim_set.name
        next
      end
      ActiveRecord::Base.transaction do
        puts exg.amount
        puts clr.amount
        exg.update_attribute(:amount, exg.amount + clr.amount)
        puts exg.amount
        clr.delete
      end
    end
  end
end