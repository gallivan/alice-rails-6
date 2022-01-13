task :ghf_claim_manual_creates_eurex_dec_21 => :environment do |t|

  ActiveRecord::Base.transaction do
    old_codes = [
      'EUREX:FGBLU21',
      'EUREX:FGBMU21',
      'EUREX:FGBSU21',
      'EUREX:FGBXU21',
      'EUREX:FESXU21'
    ]

    old_codes.each do |old_code|
      puts "Creating from example contract #{old_code}"
      new_code = old_code.gsub('U21', 'Z21')

      if Claim.find_by_code(new_code).blank?
        old_claim = Claim.find_by_code(old_code)

        new_future = Future.create! do |f|
          f.code = new_code
          f.expires_on = old_claim.expires_on + 3.months
        end

        new_claim = Claim.create! do |c|
          c.code = new_code
          # c.name = old_claim.name.gsub('2020', '2021')
          c.name = old_claim.name.gsub('Sep', 'Dec')
          c.claim_set_id = old_claim.claim_set.id
          c.size = old_claim.size
          c.point_value = old_claim.point_value
          c.point_currency_id = old_claim.point_currency.id
          c.entity_id = old_claim.entity.id
          c.claim_type_id = old_claim.claim_type.id
          c.claimable = new_future
        end
        puts new_claim.attributes
      else
        puts "#{old_code} exists. Skipping."
      end
    end

  end
end