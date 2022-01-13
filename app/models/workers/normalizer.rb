module Workers
  class Normalizer

    GMI2CLR = {
      # MONEP
      'CA' => 'FCE',
      # MATIF
      'B3' => 'EBM',
      # EUREX
      'BC' => 'FGBM',
      'BM' => 'FGBL',
      'FA' => 'FBTP',
      'SD' => 'FGBS',
      # 'SF' => 'FESX',
      'BV' => 'FGBX',
      'FE' => 'FDAX',
      'cc' => 'FBTS',
      # LIFFE
      'FT' => 'Z',
      # 'SF' => 'I',
      'RH' => 'R',
      'RJ' => 'L',
      # IFEU
      'GL' => 'G',
    }

    def self.normalize(params)
      if params['49'] =~ /(AACC|EAGLE_MARKET_MAKERS)/ and params['8'] == 'FIX.4.2'
        normalize_abn_fix_42(params)
      else
        raise "Do not know how to normalize #{params['49']} #{params['8']}"
      end
    end

    # def self.normalize_abn_pos_csv(line, posted_on)
    #   hash = {}
    #   hash[:ary] = line.split(',')
    #
    #   ary = hash[:ary]
    #
    #   ary.each_index { |i| ary[i] = ary[i].strip }
    #
    #   # replace GMI symbol with CLR symbol if known
    #   if ary[11] == '05' and ary[12] == 'SF'
    #     # LIFFE
    #     ary[12] = 'I'
    #   elsif ary[11] == '27' and ary[12] == 'SF'
    #     # EUREX
    #     ary[12] = 'FESX'
    #   else
    #     key = ary[12]
    #     ary[12] = GMI2CLR[key] if GMI2CLR.key?(key)
    #   end
    #
    #   system = System.find_by_code('AACC')
    #   hash[:system] = system
    #
    #   entity = Entity.find_by_code('EMM')
    #   hash[:entity] = entity
    #
    #   dealing_venue_alias_code = ary[11]
    #
    #   dealing_venue_alias = DealingVenueAlias.where(system_id: system.id, code: dealing_venue_alias_code).first
    #   hash[:dealing_venue] = dealing_venue_alias.dealing_venue
    #
    #   acc_code = Builders::AccountBuilder.aacc_account_alias_mundger(ary[10])
    #   account = Account.find_by_code(acc_code)
    #   # account = Builders::AccountBuilder.build_from_aacc_eod_csv(hash)
    #   claim = Builders::ClaimBuilder.build_from_abn_pos_csv(hash)
    #
    #   side = ary[20] == '1' ? +1 : -1
    #
    #   # TODO - arg ishashand returh is hash. change to params and hash.
    #   # TODO - arg ishashand returh is hash. change to params and hash.
    #   # TODO - arg ishashand returh is hash. change to params and hash.
    #   # TODO - arg ishashand returh is hash. change to params and hash.
    #
    #   hash = {
    #       account_id: account.id,
    #       system_id: system.id,
    #       entity_id: entity.id,
    #       claim_id: claim.id,
    #       done: BigDecimal(ary[21], 0) * side,
    #       price: ary[65],
    #       price_traded: ary[65],
    #       posted_on: posted_on,
    #       traded_on: posted_on,
    #       traded_at: reformat_aacc_eod_csv_time(ary[54]),
    #       dealing_venue_id: hash[:dealing_venue].id,
    #       dealing_venue_done_id: "#{posted_on} #{ary[2]}",
    #
    #       packer_report_id: hash[:packer_report_id],
    #       root: hash[:root]
    #   }
    #
    #   hash
    # end

    def self.normalized_system(code)
      if System.find_by_code(code).blank?
        raise "System with code #{code} not found."
      end
      System.find_by_code(code)
    end

    def self.normalized_entity(code)
      if Entity.find_by_code(code).blank?
        raise "Entity with code #{code} not found."
      end
      Entity.find_by_code(code)
    end

    def self.normalized_dealing_venue(hash)
      dealing_venue_alias_code = hash[:ary][12]
      dealing_venue_alias = DealingVenueAlias.where(system_id: hash[:system].id, code: dealing_venue_alias_code).first
      dealing_venue_alias.dealing_venue
    end

    def self.normalized_side(hash)
      hash[:ary][11] == '1' ? +1 : -1
    end

    def self.normalize_itd_abn_csv(hash)
      hash[:ary] = hash[:csv].split(',')
      hash[:system] = normalized_system('ABN_MICS')
      hash[:entity] = normalized_entity('EMM')
      hash[:dealing_venue] = normalized_dealing_venue(hash)
      account = Builders::AccountBuilder.build_from_aacc_itd_csv(hash)
      claim = Builders::ClaimBuilder.build_from_aacc_itd_csv(hash)
      side = normalized_side(hash)
      hash = {
        account_id: account.id,
        system_id: hash[:system].id,
        entity_id: hash[:entity].id,
        claim_id: claim.id,
        done: BigDecimal(hash[:ary][10], 0) * side,
        price: hash[:ary][19],
        price_traded: hash[:ary][19],
        posted_on: reformat_mics_itd_csv_date(hash[:ary][0]),
        traded_on: reformat_mics_itd_csv_date(hash[:ary][21]),
        traded_at: reformat_mics_itd_csv_time(hash[:ary][40]),
        dealing_venue_id: hash[:dealing_venue].id,
        dealing_venue_done_id: "#{Time.now.to_i} #{hash[:ary][9]}",
        packer_report_id: hash[:packer_report_id],
        root: hash[:root]
      }

      hash
    end

    def self.reformat_mics_itd_csv_date(str)
      # 12/2/2019
      # 11/22/2019
      # 1/22/2019
      # 1/2/2019
      # 11/22/2019 3:04:40 AM
      str = str.split.first # defaults to space split
      m, d, y = str.split('/')
      date = Date.parse([y, m, d].join('-'))
      date.strftime("%Y-%m-%d")
    end

    def self.reformat_mics_itd_csv_time(str)
      # 11/22/2019 3:04:40 AM
      a, b, c = str.split
      m, d, y = a.split('/')
      date = Date.parse([y, m, d].join('-'))
      x = date.strftime("%Y-%m-%d")
      time = Time.parse("#{x} #{b} #{c}")
      time.strftime('%H:%M:%S')
    end

    def self.build_aacc_eod_csv_trade_id(hash)
      [hash[:ary][18],].join(':')
    end

    # {"FIXML"=>
    #   {"TrdCaptRpt"=>
    #     {"RptID"=>"21937832663",
    #      "TrdTyp"=>"0",
    #      "TrdSubTyp"=>"7",
    #      "ExecID"=>"87472920160720190002TN0000015",
    #      "TrdDt"=>"2016-07-21",
    #      "BizDt"=>"2016-07-21",
    #      "MLegRptTyp"=>"2",
    #      "MtchStat"=>"0",
    #      "MsgEvtSrc"=>"REG",
    #      "TrdID"=>"100432",
    #      "LastQty"=>"1",
    #      "LastPx"=>"347.7",
    #      "TxnTm"=>"2016-07-20T19:00:02-05:00",
    #      "SettlCcy"=>"USD",
    #      "SettlDt"=>"2016-12-14",
    #      "OrigTrdID"=>"155FADF8568LTP0202D90652A",
    #      "PxSubTyp"=>"1",
    #      "VenueTyp"=>"E",
    #      "VenuTyp"=>"E",
    #      "Instrmt"=>
    #       {"ID"=>"06",
    #        "Desc"=>"SOYBEAN MEAL FUTURES",
    #        "CFI"=>"FCAPSO",
    #        "SecTyp"=>"FUT",
    #        "MMY"=>"201612",
    #        "MatDt"=>"2016-12-14",
    #        "Mult"=>"100",
    #        "Exch"=>"CBT",
    #        "UOM"=>"tn",
    #        "UOMQty"=>"100",
    #        "PxUOM"=>"TON",
    #        "PxUOMQty"=>"1",
    #        "ValMeth"=>"FUT",
    #        "Fctr"=>"1",
    #        "PxQteCcy"=>"USD"},
    #      "Amt"=>{"Typ"=>"TVAR", "Amt"=>"20", "Ccy"=>"USD"},
    #      "RptSide"=>
    #       {"Side"=>"2",
    #        "ClOrdID"=>"17W9",
    #        "CustCpcty"=>"2",
    #        "OrdTyp"=>"L",
    #        "SesID"=>"EOD",
    #        "SesSub"=>"E",
    #        "AllocInd"=>"0",
    #        "AgrsrInd"=>"Y",
    #        "Pty"=>
    #         [{"ID"=>"CME", "R"=>"21"},
    #          {"ID"=>"353", "R"=>"4"},
    #          {"ID"=>"CBT", "R"=>"22"},
    #          {"ID"=>"330", "R"=>"1"},
    #          {"ID"=>"00333", "R"=>"24", "Sub"=>{"ID"=>"2", "Typ"=>"26"}},
    #          {"ID"=>"3E3L", "R"=>"12"},
    #          {"ID"=>"330B", "R"=>"38", "Sub"=>{"ID"=>"2", "Typ"=>"26"}},
    #          {"ID"=>"330", "R"=>"7"}],
    #        "RegTrdID"=>
    #         {"ID"=>"FECF155FADF8568LTP0202D90652E",
    #          "Src"=>"1010000023",
    #          "Typ"=>"0",
    #          "Evnt"=>"2"}}}}}

    def self.normalize_cme_eod(params)
      system = System.find_by_code('CMEsys')
      params[:system] = system

      entity = Entity.find_by_code('EMM')
      params[:entity] = entity

      dealing_venue_alias_code = params['FIXML']['TrdCaptRpt']['Instrmt']['Exch']

      dealing_venue_alias = DealingVenueAlias.where(system_id: system.id, code: dealing_venue_alias_code).first
      params[:dealing_venue] = dealing_venue_alias.dealing_venue

      account = Builders::AccountBuilder.build_from_cme_eod(params)
      claim = Builders::ClaimBuilder.build_from_cme_eod(params)

      side = params['FIXML']['TrdCaptRpt']['RptSide']['Side'] == '1' ? +1 : -1

      exec_id = params['FIXML']['TrdCaptRpt']['ExecID']
      trd_id = params['FIXML']['TrdCaptRpt']['TrdID']

      hash = {
        account_id: account.id,
        system_id: system.id,
        entity_id: entity.id,
        claim_id: claim.id,
        done: BigDecimal(params['FIXML']['TrdCaptRpt']['LastQty'], 0) * side,
        price: params['FIXML']['TrdCaptRpt']['LastPx'],
        price_traded: params['FIXML']['TrdCaptRpt']['LastPx'],
        posted_on: params['FIXML']['TrdCaptRpt']['BizDt'],
        traded_on: params['FIXML']['TrdCaptRpt']['TrdDt'],
        traded_at: params['FIXML']['TrdCaptRpt']['TxnTm'],
        dealing_venue_id: params[:dealing_venue].id,
        # dealing_venue_done_id: params['FIXML']['TrdCaptRpt']['ExecID'],
        dealing_venue_done_id: "#{exec_id} #{trd_id}",

        packer_report_id: params[:packer_report_id],
        root: params[:root]
      }

      hash
    end

    def self.normalize_cme_itd_fixml(fixml)
      hash = {}

      doc = Nokogiri::XML(fixml)

      system = System.find_by_code('CME_FIX_ITD')
      account_alias_code = doc.css('FIXML TrdCaptRpt RptSide Pty')[4]['ID']
      account_alias = AccountAlias.find_by_system_id_and_code(system.id, account_alias_code)

      claim = cme_fixml_claim_mapper(doc, fixml)

      hash[:account_id] = account_alias.account_id
      hash[:claim_id] = claim.id
      hash[:done] = doc.css('FIXML TrdCaptRpt').first['LastQty'].to_i
      hash[:done] *= (doc.css('FIXML TrdCaptRpt RptSide').first['Side'] =~ /1/) ? +1 : -1
      hash[:price] = BigDecimal(doc.css('FIXML TrdCaptRpt').first['LastPx'], 9)
      hash[:price_traded] = hash[:price]
      hash[:posted_on] = Date.parse(doc.css('FIXML TrdCaptRpt').first['BizDt'])
      hash[:traded_on] = Date.parse(doc.css('FIXML TrdCaptRpt').first['TrdDt'])

      hash
    end

    # fix 4.2 https://rubygems.org/gems/fix-protocol/versions/1.1.2

    # foo = {"8"=>"FIX.4.2", "9"=>"1446", "35"=>"8", "34"=>"1673", "49"=>"AACC", "52"=>"20160128-16:29:46.155", "56"=>"EAGLE_MARKET_MAKERS", "1"=>"6901E0877", "6"=>"314.25", "11"=>"201197609609", "14"=>"1", "17"=>"210406165", "20"=>"0", "31"=>"314.25", "32"=>"1", "37"=>"210406165", "38"=>"1", "39"=>"2", "44"=>"314.25", "54"=>"1", "55"=>"G", "60"=>"20160128-16:29:36", "75"=>"20160128", "76"=>"JHG", "150"=>"2", "151"=>"0", "167"=>"FUT", "200"=>"201603", "207"=>"16", "231"=>"100", "439"=>"690", "440"=>"E0877", "9028"=>"1", "9029"=>"Future", "9031"=>"NGRM", "9032"=>"655", "9033"=>"20160128/FCR/IFEU/4106894", "9034"=>"E0877", "9037"=>"20160310", "9038"=>"2", "9039"=>"<FIXML><TrdCaptRpt RptID~\"353795\" CopyMsgInd~\"Y\" TrdRptStat~\"0\" TrdID~\"4106894\" LastPx~\"314.25\" LastQty~\"1\" TrdDt~\"2016-01-28\" BizDt~\"2016-01-28\" TxnTm~\"2016-01-28T11:29:36-05:00\" TrdTyp~\"0\" MtchStat~\"0\" VenuTyp~\"E\" ExecID~\"12713436\" MLegRptTyp~\"2\" TrdPubInd~\"1\" RptTyp~\"0\" TransTyp~\"0\"><Hdr Snt~\"2016-01-28T11:29:37-05:00\" SID~\"ICE\" TID~\"FCR\"/><RegTrdID Typ~\"0\" ID~\"10000000000000000000000000NYZW58\" Src~\"1010000180\" Evnt~\"2\"/><TrdRegTS Typ~\"19\" TS~\"2016-01-28T11:29:37.385-05:00\"/><TrdRegTS Typ~\"1\" TS~\"2016-01-28T11:29:37.381-05:00\"/><Pty R~\"73\" ID~\"IFEU\"/><Instrmt ID~\"G\" SecTyp~\"FUT\" MMY~\"201603\" Exch~\"IFEU\" SubTyp~\"99\"/><RptSide Side~\"1\" OrdID~\"12713418\" ClOrdID2~\"521539299\" AgrsrInd~\"Y\" ClOrdID~\"201197609609\" InptSrc~\"ICE\" InptDev~\"ICE\" PosEfct~\"O\" StrategyLinkID~\"12713418\"><Pty R~\"12\" ID~\"JHG\"/><Pty R~\"21\" ID~\"ICEU\"/><Pty R~\"4\" ID~\"FCR\"/><Pty R~\"1\" ID~\"FCR\"/><Pty R~\"22\" ID~\"IFEU\"/><Pty R~\"38\" ID~\"W\"><Sub ID~\"4\" Typ~\"26\"/></Pty><Pty R~\"24\" ID~\"E0877\"/><Pty R~\"44\" ID~\"NGRM\"/><Pty R~\"55\" ID~\"ngremmemm\"/></RptSide></TrdCaptRpt></FIXML>", "10"=>"143"}

    # <FIXML>
    #    <TrdCaptRpt RptID="353795" CopyMsgInd="Y" TrdRptStat="0" TrdID="4106894" LastPx="314.25" LastQty="1" TrdDt="2016-01-28" BizDt="2016-01-28" TxnTm="2016-01-28T11:29:36-05:00" TrdTyp="0" MtchStat="0" VenuTyp="E" ExecID="12713436" MLegRptTyp="2" TrdPubInd="1" RptTyp="0" TransTyp="0">
    #       <Hdr Snt="2016-01-28T11:29:37-05:00" SID="ICE" TID="FCR" />
    #       <RegTrdID Typ="0" ID="10000000000000000000000000NYZW58" Src="1010000180" Evnt="2" />
    #       <TrdRegTS Typ="19" TS="2016-01-28T11:29:37.385-05:00" />
    #       <TrdRegTS Typ="1" TS="2016-01-28T11:29:37.381-05:00" />
    #       <Pty R="73" ID="IFEU" />
    #       <Instrmt ID="G" SecTyp="FUT" MMY="201603" ="IFEU" SubTyp="99" />
    #       <RptSide Side="1" OrdID="12713418" ClOrdID2="521539299" AgrsrInd="Y" ClOrdID="201197609609" InptSrc="ICE" InptDev="ICE" PosEfct="O" StrategyLinkID="12713418">
    #          <Pty R="12" ID="JHG" />
    #          <Pty R="21" ID="ICEU" />
    #          <Pty R="4" ID="FCR" />
    #          <Pty R="1" ID="FCR" />
    #          <Pty R="22" ID="IFEU" />
    #          <Pty R="38" ID="W">
    # </FIXML>

    def self.normalize_abn_fix_42(params)
      system = System.find_by_code('AACC')
      params[:system] = system

      entity = Entity.find_by_code('EMM')
      params[:entity] = entity

      dealing_venue_alias = DealingVenueAlias.where(system_id: system.id, code: params['207']).first
      dealing_venue = dealing_venue_alias.dealing_venue
      params[:dealing_venue] = dealing_venue

      account = Builders::AccountBuilder.build_from_aacc_fix_42(params)
      claim = Builders::ClaimBuilder.build_from_aacc_fix_42(params)

      hash = {
        account_id: account.id,
        system_id: system.id,
        entity_id: entity.id,
        claim_id: claim.id,
        done: params['54'] == '1' ? params['32'] : '-' + params['32'],
        price: params['31'],
        price_traded: params['31'],
        posted_on: params['75'],
        traded_on: params['75'],
        traded_at: params['60'],
        dealing_venue_id: dealing_venue.id,
        dealing_venue_done_id: params['17']
      }

      hash
    end

    def self.normalize_baseline_report(report)

      account_code, posted_on, done, claim_code, price = report.split(' ')

      puts claim_code

      date = Date.parse(posted_on)
      venue = DealingVenue.find_by_code(claim_code.split(':').first)
      claim = Claim.find_by_code(claim_code)
      system = System.find_by_code('BKO')
      entity = Entity.find_by_code('EMM')
      account = Account.find_by_code(account_code)

      hash = {
        account_id: account.id,
        system_id: system.id,
        entity_id: entity.id,
        claim_id: claim.id,
        done: done,
        price: price,
        price_traded: price,
        posted_on: date,
        traded_on: date,
        traded_at: date,
        dealing_venue_id: venue.id,
        dealing_venue_done_id: rand(1_000_000_000)
      }

      hash
    end

    def self.normalize_eod_ghf_csv(params)
      system = System.find_by_code('GHF MIR13_LON')
      params[:system] = system

      entity = Entity.find_by_code('EMM')
      params[:entity] = entity

      params[:csv] = params[:csv].gsub(' ', '') # remove spaces. they appear to have no value and confuse split.
      params[:ary] = params[:csv].split(',')

      dealing_venue_code = params[:ary][31]
      params[:dealing_venue] = DealingVenue.find_by_code(dealing_venue_code)

      params[:account_code] = params[:ary][3]

      account_alias = AccountAlias.find_by_system_id_and_code(system.id, params[:account_code])
      if account_alias.blank?
        raise "AccountAlias not setup for GHF system #{system.code} and account code #{params[:account_code]}"
      else
        account = account_alias.account
      end
      claim = Builders::ClaimBuilder.build_claim_from_ghf_csv(params)

      hash = {
        account_id: account.id,
        system_id: system.id,
        entity_id: entity.id,
        claim_id: claim.id,
        done: params[:ary][9] == 'B' ? params[:ary][10] : '-' + params[:ary][10],
        price: params[:ary][12],
        price_traded: params[:ary][12],
        posted_on: Date.parse(params[:ary][13]),
        traded_on: Date.parse(params[:ary][13]),
        traded_at: DateTime.parse("#{params[:ary][26]} #{params[:ary][13]}"),
        dealing_venue_id: params[:dealing_venue].id,
        dealing_venue_done_id: "#{params[:ary][40]} #{params[:ary][15]}" # UTI and TradeNo
      }

      hash
    end

    private

    def self.cme_fixml_claim_mapper(doc, fixml)
      claim_code = doc.css('FIXML TrdCaptRpt Instrmt').first['Sym'] # GEM4
      claim_root = doc.css('FIXML TrdCaptRpt Instrmt').first['Sym'] # ED
      claim_mnth = claim_code.split(//).last(2).join
      claim_code = claim_root + claim_mnth
      claim = Claim.find_by_code(claim_code)
      claim = Builders::ClaimBuilder.build_from_cme_fixml_itd(fixml) if claim.blank?
      claim
    end

  end
end
