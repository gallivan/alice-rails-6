task :add_adjustments_20170522 => :environment do

  data = <<HERE
05/22/17::88888:To adjust for incorrect coding of Exchange fees:FEE:SEGN:0.09:EUR
05/22/17::00777:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-4220.66:USD
05/22/17::00789:To adjust for incorrect coding of Exchange fees:FEE:SEGN:88.00:GBP
05/22/17::00789:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-2105.00:USD
05/22/17::01985:To adjust for incorrect coding of Exchange fees:FEE:SEGN:93.60:USD
05/22/17::01986:To adjust for incorrect coding of Exchange fees:FEE:SEGN:0.02:USD
05/22/17::04779:To adjust for incorrect coding of Exchange fees:FEE:SEGN:4.74:USD
05/22/17::05520:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-153.43:USD
05/22/17::05520:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1829.96:GBP
05/22/17::39009:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-9.50:EUR
05/22/17::39009:To adjust for incorrect coding of Exchange fees:FEE:SEGN:4570.28:GBP
05/22/17::39009:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-150.26:USD
05/22/17::88888:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-0.05:USD
05/22/17::08888:To adjust Account number to correct account 88888:MSC:SEGN:648.06:USD
05/22/17::08888:To adjust Account number to correct account 88888:MSC:SEGN:949.36:EUR
05/22/17::88888:To adjust Account number to correct account 88888:MSC:SEGN:-648.06:USD
05/22/17::88888:To adjust Account number to correct account 88888:MSC:SEGN:-949.36:EUR
05/22/17::00201:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-6372.85:USD
05/22/17::01974:To adjust for incorrect coding of Exchange fees:FEE:SEGN:2481.30:USD
05/22/17::00024:To adjust for incorrect coding of Exchange fees:FEE:SEGN:3.08:USD
05/22/17::00024:To adjust for incorrect coding of Exchange fees:FEE:SEGN:2868.36:GBP
05/22/17::00033:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1761.76:GBP
05/22/17::00071:To adjust for incorrect coding of Exchange fees:FEE:SEGN:0.02:USD
05/22/17::00071:To adjust for incorrect coding of Exchange fees:FEE:SEGN:352.00:GBP
05/22/17::00085:To adjust for incorrect coding of Exchange fees:FEE:SEGN:125.16:USD
05/22/17::00085:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1883.20:GBP
05/22/17::00099:To adjust for incorrect coding of Exchange fees:FEE:SEGN:501.89:USD
05/22/17::00099:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-2.00:EUR
05/22/17::00123:To adjust for incorrect coding of Exchange fees:FEE:SEGN:176.00:GBP
05/22/17::00333:To adjust for incorrect coding of Exchange fees:FEE:SEGN:891.44:GBP
05/22/17::00375:To adjust for incorrect coding of Exchange fees:FEE:SEGN:48.60:USD
05/22/17::00429:To adjust for incorrect coding of Exchange fees:FEE:SEGN:282.48:GBP
05/22/17::00429:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-95.29:USD
05/22/17::00451:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-336.04:USD
05/22/17::00455:To adjust for incorrect coding of Exchange fees:FEE:SEGN:176.00:GBP
05/22/17::00624:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-114.48:EUR
05/22/17::00624:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1838.00:GBP
05/22/17::00624:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-53.26:USD
05/22/17::00708:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1575.92:USD
05/22/17::00708:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1070.96:GBP
05/22/17::00902:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-104.61:USD
05/22/17::00002:To adjust for incorrect coding of Exchange fees:FEE:SEGN:3663.44:GBP
05/22/17::00002:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-57.56:EUR
05/22/17::00002:To adjust for incorrect coding of Exchange fees:FEE:SEGN:6407.79:USD
05/22/17::00005:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-9.59:USD
05/22/17::00005:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-101.30:EUR
05/22/17::00005:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1140.48:GBP
05/22/17::00019:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-0.06:EUR
05/22/17::00019:To adjust for incorrect coding of Exchange fees:FEE:SEGN:2219.47:USD
05/22/17::00019:To adjust for incorrect coding of Exchange fees:FEE:SEGN:1468.72:GBP
05/22/17::00022:To adjust for incorrect coding of Exchange fees:FEE:SEGN:132.00:GBP
05/22/17::00022:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-301.16:USD
05/22/17::00877:To adjust for incorrect coding of Exchange fees:FEE:SEGN:-14.04:EUR
05/22/17::00877:To adjust for incorrect coding of Exchange fees:FEE:SEGN:29.94:USD
05/22/17::00877:To adjust for incorrect coding of Exchange fees:FEE:SEGN:5598.56:GBP
05/22/17::00902:To adjust for incorrect coding of Exchange fees:FEE:SEGN:2530.88:GBP
05/22/17::00099:Trader Development Rebate March 2017:FEE:SEGN:818.00:EUR
05/22/17::01986:Trader Development Rebate March 2017:FEE:SEGN:548.00:EUR
HERE

  data.lines.each do |line|
    puts line
    posted_on, as_of_on, account_code, memo, adjustment_code, segregation_code, amount, ccy_code = line.chomp.split(/:/)

    params = {}

    params[:adjustment_type_id] = AdjustmentType.find_by_code(adjustment_code).id
    params[:segregation_id] = Segregation.find_by_code(segregation_code).id
    params[:currency_id] = Currency.find_by_code(ccy_code).id
    params[:account_id] = Account.find_by_code(account_code).id
    params[:posted_on] = '2017-05-22'
    params[:as_of_on] = '2017-05-22'
    params[:amount] = amount
    params[:memo] = memo

    puts params

    Adjustment.transaction do
      begin
        Builders::AdjustmentBuilder.build(params)
      rescue Exception => e
        puts e.message
      end
    end

  end

end
