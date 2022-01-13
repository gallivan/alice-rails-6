task :ghf_claim_manual_creates_eurex_jun_sep_21_roll => :environment do |t|

  ActiveRecord::Base.transaction do
    old_codes = [
      'EUREX:FGBLM20', 'EUREX:FGBLU20',
      'EUREX:FGBMM20', 'EUREX:FGBMU20',
      'EUREX:FGBSM20', 'EUREX:FGBSU20',
      'EUREX:FGBXM20', 'EUREX:FGBXU20',
      'EUREX:FESXM20', 'EUREX:FESXU20'
    ]

    old_codes.each do |old_code|
      new_code = old_code.gsub('20', '21')

      if Claim.find_by_code(new_code).blank?
        old_claim = Claim.find_by_code(old_code)

        new_future = Future.create! do |f|
          f.code = new_code
          f.expires_on = old_claim.expires_on + 1.year
        end

        new_claim = Claim.create! do |c|
          c.code = new_code
          c.name = old_claim.name.gsub('2020', '2021')
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