task :populate_dealing_venue_associations => :environment do
  ClaimSet.all.order(:code).each do |s|
    venue_code = s.code.split(':').first
    puts venue_code

    #
    # TODO needa better definition of DealingVenue
    #

    venue = DealingVenue.find_by_code venue_code
    if venue.blank?
      puts "missing"
    else
      puts "found"
    end
  end
end