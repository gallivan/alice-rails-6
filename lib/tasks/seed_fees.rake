task :seed_fees => :environment do

  settings = [
      "EXG|EUR|0.30|EUREX:FESX|EUREX:EURO STOXX 50",
      "EXG|EUR|0.20|EUREX:FGBM|EUREX:EURO-BOBL",
      "EXG|EUR|0.20|EUREX:FGBS|EUREX:EURO SCHATZ",
      "EXG|EUR|0.20|EUREX:FGBL|EUREX:EURO-BUND",
      "EXG|EUR|0.20|EUREX:FGBX|EUREX:EURO-BUXL",
      "EXG|EUR|0.50|EUREX:FDAX|EUREX:DAX",
      "EXG|EUR|0.20|EUREX:FBTP|EUREX:LONG-TERM EURO-BTP",
      "EXG|EUR|0.20|EUREX:FBTS|EUREX:SHORT-TERM EURO-BTP",

      "EXG|GBP|0.28|LIFFE:Z|LIFFE:FTSE INDEX 100",
      "EXG|GBP|0.28|LIFFE:R|LIFFE:LONG GILT",
      "EXG|GBP|0.23|LIFFE:L|LIFFE:3M STERLING",

      "CLR|EUR|0.70|MATIF:EBM|MATIF:MILLING WHEAT",
      "EXG|EUR|0.25|MATIF:EBM|MATIF:MILLING WHEAT",

      "CLR|USD|0.09|IFEU:G|IFEU:GAS-OIL",
      "EXG|USD|0.73|IFEU:G|IFEU:GAS-OIL",

      "EXG|USD|0.14|CBT:C|CBT:CORN FUTURES",
      "CLR|USD|0.06|CBT:C|CBT:CORN FUTURES",
      "EXG|USD|0.14|CBT:W|CBT:WHEAT FUTURES",
      "CLR|USD|0.06|CBT:W|CBT:WHEAT FUTURES",
      "EXG|USD|0.14|CBT:S|CBT:SOYBEAN FUTURES",
      "CLR|USD|0.06|CBT:S|CBT:SOYBEAN FUTURES",
      "EXG|USD|0.14|CBT:06|CBT:SOYBEAN MEAL FUTURES",
      "CLR|USD|0.06|CBT:06|CBT:SOYBEAN MEAL FUTURES",
      "EXG|USD|0.14|CBT:07|CBT:SOYBEAN OIL FUTURES",
      "CLR|USD|0.06|CBT:07|CBT:SOYBEAN OIL FUTURES",
      "EXG|USD|0.14|CBT:KW|CBT:KC HRW WHEAT FUTURES",
      "CLR|USD|0.06|CBT:KW|CBT:KC HRW WHEAT FUTURES",

      "EXG|USD|0.10|CBT:YM|CBT:E-MINI DOW JONES INDEX FUTURES",
      "CLR|USD|0.06|CBT:YM|CBT:E-MINI DOW JONES INDEX FUTURES",

      "EXG|USD|0.06|CBT:21|CBT:10 YEAR TREASURY NOTE FUTURES",
      "CLR|USD|0.06|CBT:21|CBT:10 YEAR TREASURY NOTE FUTURES",
      "EXG|USD|0.06|CBT:25|CBT:5 YEAR TREASURY NOTE FUTURES",
      "CLR|USD|0.06|CBT:25|CBT:5 YEAR TREASURY NOTE FUTURES",
      "EXG|USD|0.06|CBT:26|CBT:2 YEAR TREASURY NOTE FUTURES",
      "CLR|USD|0.06|CBT:26|CBT:2 YEAR TREASURY NOTE FUTURES",
      "EXG|USD|0.06|CBT:17|CBT:30 YR U.S. TREASURY BOND FUTURES",
      "CLR|USD|0.06|CBT:17|CBT:30 YR U.S. TREASURY BOND FUTURES",
      "EXG|USD|0.06|CBT:UBE|CBT:LONG TERM U.S. TREASURY BOND FUTURES",
      "CLR|USD|0.06|CBT:UBE|CBT:LONG TERM U.S. TREASURY BOND FUTURES",

      "EXG|USD|0.20|CME:48|CME:LIVE CATTLE FUTURES",
      "EXG|USD|0.20|CME:LN|CME:LEAN HOG FUTURES",

      "EXG|USD|0.10|CME:ED|CME:EURODOLLAR FUTURES",
      "EXG|USD|0.11|CME:ES|CME:E-MINI S&P 500 FUTURES",

      "EXG|USD|1.45|NYMEX:CL|NYMEX:CRUDE OIL FUTURES",
      "EXG|USD|0.45|NYMEX:BZ|NYMEX:BRENT LAST DAY CONTRACT",
      "EXG|USD|0.45|NYMEX:NG|NYMEX:NATURAL GAS HENRY HUB FUTURES",
  ]

  #
  # create fees for settings
  #

  settings.each do |setting|
    # puts setting

    fee_chargeable_type_code, currency_code, amount, claim_set_code, claim_set_name = setting.split('|')

    currency = Currency.find_by_code(currency_code)
    claim_set = ClaimSet.find_by_code(claim_set_code)
    fee_chargeable_type = FeeChargeableType.find_by_code(fee_chargeable_type_code)

    if claim_set.blank?
      puts "ClaimSet missing. Skipping."
      next
    end

    params = {
        currency_id: currency.id,
        claim_set_id: claim_set.id,
        fee_chargeable_type_id: fee_chargeable_type.id
    }

    print "Checking #{fee_chargeable_type.code} fee for ClaimSet #{claim_set.code}: "

    fee_chargeable = FeeChargeable.where(params).first

    if fee_chargeable.blank?
      puts 'creating.'
      params.merge!(
          {
              amount: BigDecimal(amount, 8),
              begun_on: 1.year.ago,
              ended_on: 2.years.from_now
          }
      )
      puts params.inspect
      FeeChargeable.create!(params)
    else
      puts 'updating.'
      fee_chargeable.update_attribute(:amount, BigDecimal(amount, 8))
    end
  end

  #
  # create service fee for each claim set
  #

  srv = FeeChargeableType.find_by_code('SRV')
  ids = FeeChargeable.distinct(:claim_set_id).order(:claim_set_id).pluck(:claim_set_id)

  ids.each do |id|
    claim_set = ClaimSet.find(id)
    params = {
        currency_id: Currency.usd.id,
        claim_set_id: claim_set.id,
        fee_chargeable_type_id: srv.id
    }

    fee_chargeable = FeeChargeable.where(params).first

    print "Checking SRV fee for ClaimSet #{claim_set.code}: "

    if fee_chargeable.blank?
      puts 'creating.'
      params.merge!(
          {
              amount: BigDecimal(0.035, 8),
              begun_on: 1.year.ago,
              ended_on: 2.years.from_now
          }
      )
      # puts params.inspect
      FeeChargeable.create!(params)
    else
      puts "found and skipping"
    end
  end

end
