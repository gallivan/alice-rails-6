task :rebuild_claim_names => :environment do |t, args|
  Claim.order(:claim_set_id).each do |claim|
    old_name = claim.name
    new_name = claim.claim_set.name + "#{claim.expires_on.strftime(' %b %Y')}"
    unless new_name.match(old_name)
      puts "name change"
      puts old_name
      puts new_name
      claim.update_attribute(:name, new_name)
    end
  end
end