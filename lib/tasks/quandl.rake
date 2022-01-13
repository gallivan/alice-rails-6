namespace :quandl do
  task :backfill_prices_and_volumes, [:period_began_on, :period_ended_on] => :environment do |t, args|
    begin
      period_began_on = Date.parse(args[:period_began_on])
      period_ended_on = Date.parse(args[:period_ended_on])
      Workers::QuandlDAO.backfill_prices_and_volumes(period_began_on, period_ended_on)
    rescue Exception => e
      puts "Invalid argument: #{e}"
      puts "Usage: rake quandl:backfill_prices_and_volumes[yyyy-mm-dd,yyyy-mm-dd]"
      exit
    end
  end

  task :claim_name_reset_all => :environment do
    ClaimSet.order(:code).all.each do |claim_set|
      claim_set.claims.order(:code).each do |claim|
        name = Workers::QuandlDAO.get_claim_name(claim)
        reset_names(claim, name)
      end
    end
  end

  task :claim_name_reset_fixme => :environment do
    Claim.where("name like '%[fixme]%'").order(:code).each do |claim|
      name = Workers::QuandlDAO.get_claim_name(claim)
      reset_names(claim, name)
    end
  end

  def reset_names(claim, name)
    # Soybean Meal Futures, December 2016 (SMZ2016)
    name = name[0..(name.rindex(' ') - 1)]
    claim.update_attribute(:name, name)
    claim_set_name = name.split(/,/).first
    claim_set = claim.claim_set
    claim_set.update_attribute(:name, claim_set_name) unless claim_set.name == claim_set_name
  end

  task :post_claim_marks_for_date, [:date] => :environment do |t, args|
    begin
      date = Date.parse(args[:date])

      claims = ClaimMark.claims_to_mark_for_date(date)

      while ClaimMark.missing_marks_for_date?(date) do
        Workers::QuandlDAO.get_quandl_marks(date, claims)
        if ClaimMark.missing_marks_for_date?(date)
          puts "Missing ClaimMark"
          "Sleeping until #{5.minutes.from_now}"
          sleep 5.minutes
        end
      end
    rescue Exception => e
      puts "Invalid argument: #{e}"
      puts "Usage: rake quandl:post_claim_marks_for_date[yyyy-mm-dd]"
      exit
    end

  end
end