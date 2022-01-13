task :seed_commissions => :environment do

  settings = [
      "BRK|USD|0.05|MATIF:EBM|MATIF:MILLING WHEAT",
      "BRK|USD|0.05|EUREX:FGBM|EUREX:EURO-BOBL",
      "BRK|USD|0.05|EUREX:FESX|EUREX:EURO STOXX 50",
      "BRK|USD|0.05|IFEU:G|IFEU:GAS-OIL",
      "BRK|USD|0.05|EUREX:FGBS|EUREX:EURO SCHATZ",
      "BRK|USD|0.05|LIFFE:R|LIFFE:LONG GILT",
      "BRK|USD|0.05|LIFFE:L|LIFFE:3M STERLING",
      "BRK|USD|0.05|EUREX:FGBL|EUREX:EURO-BUND",
      "BRK|USD|0.05|EUREX:FGBX|EUREX:EURO-BUXL",
      "BRK|USD|0.05|LIFFE:Z|LIFFE:FTSE INDEX 100",
      "BRK|USD|0.05|EUREX:FDAX|EUREX:DAX",
      "BRK|USD|0.07|EUREX:FBTP|EUREX:LONG-TERM EURO-BTP",
      "BRK|USD|0.05|EUREX:FBTS|EUREX:SHORT-TERM EURO-BTP",
  ]

  settings.each do |setting|
    puts setting

    commission_chargeable_type_code, currency_code, amount, claim_set_code, claim_set_name = setting.split('|')

    currency = Currency.find_by_code(currency_code)
    claim_set = ClaimSet.find_by_code(claim_set_code)
    commission_chargeable_type = CommissionChargeableType.find_by_code(commission_chargeable_type_code)

    if claim_set.blank?
      puts "ClaimSet missing. Skipping."
      next
    end

    params = {
        currency_id: currency.id,
        claim_set_id: claim_set.id,
        commission_chargeable_type_id: commission_chargeable_type.id
    }

    commission_chargeable = CommissionChargeable.where(params).first

    if commission_chargeable.blank?
      puts 'Not found. Creating.'
      params.merge!(
          {
              amount: BigDecimal(amount, 8),
              begun_on: 1.year.ago,
              ended_on: 2.years.from_now
          }
      )
      puts params.inspect
      CommissionChargeable.create!(params)
    else
      puts 'Found. Ignoring.'
    end
  end

end