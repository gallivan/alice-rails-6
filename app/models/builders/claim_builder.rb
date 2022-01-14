module Builders

  class ClaimBuilder

    L2N = {
        'F' => '01',
        'G' => '02',
        'H' => '03',
        'J' => '04',
        'K' => '05',
        'M' => '06',
        'N' => '07',
        'Q' => '08',
        'U' => '09',
        'V' => '10',
        'X' => '11',
        'Z' => '12'
    }

    N2L = L2N.invert

    N2M = {
        "01" => "Jan",
        "02" => "Feb",
        "03" => "Mar",
        "04" => "Apr",
        "05" => "May",
        "06" => "Jun",
        "07" => "Jul",
        "08" => "Aug",
        "09" => "Sep",
        "10" => "Oct",
        "11" => "Nov",
        "12" => "Dec"
    }

    M2N = N2M.invert

    def self.build_from_ard(line)
      #* CBT    06         201703                                                   SOYBEAN MEAL FUTURES                               SETTLEMENT PRICE:         332.80      USD *
      line = line.gsub(/\s+/, ' ').gsub('* ', '').gsub(' *', '')
      # puts line
      ary = line.split(/ /)
      maturity_code = ary[2]
      maturity_code = N2L[maturity_code[-2, 2]] + maturity_code[2, 2]
      code = ary[0] + ':' + ary[1] + maturity_code
      claim = Claim.find_by_code(code)
      # if claim.blank?
      #   puts "Claim #{code} not found"
      # else
      #   puts "Claim #{code} found"
      # end
      claim
    end

    def self.build_from_fix_42(params)
      claim_alias = find_aacc_claim_alias(params)

      if claim_alias.blank?
        claim = build_from_aacc_fix_42(params)
        ClaimAliasBuilder.build_for_acc(params)
      else
        claim = claim_alias.claim
      end

      claim
    end

    def self.find_aacc_claim_alias(params)
      system = System.find_by_code('AACC')
      code = "#{params['207']}:#{params['55']}:#{params['200']}"
      ClaimAlias.find_by_system_id_and_code(system.id, code)
    end

    def self.build_from_aacc_itd_csv(params)
      system = params[:system]
      dealing_venue = params[:dealing_venue]

      currency_code = params[:ary][14]

      exchange_code_alias = params[:ary][12]
      claim_set_code_alias = params[:ary][13]
      maturity_code = params[:ary][15]

      claim_set = get_claim_set_aacc_itd_csv(params)

      claim_alias_code = "#{exchange_code_alias}:#{claim_set_code_alias}:#{maturity_code}"
      claim_alias = ClaimAlias.find_by_code(claim_alias_code)

      if claim_alias
        claim_alias.claim
      else
        currency = Currency.find_by_code(currency_code) or raise "Could not find Currency #{currency_code} for System #{system.code}."
        claim_type = ClaimType.find_by_code('FUT') or raise "Could not find ClaimType Code FUT for System #{system.code}."

        maturity_code = L2N.invert[params[:ary][15][-2, 2]] + params[:ary][15][2, 2]
        maturity_name = "#{N2M[params[:ary][15][-2, 2]]} #{params[:ary][15][0..3]}"

        claim_code = "#{claim_set.code}#{maturity_code}"
        claim_name = "#{params[:ary][33]} #{maturity_name}"

        Rails.logger.info "Checking for Claim #{claim_code}..."

        claim = Claim.find_by_code(claim_code)

        if claim.blank?
          Rails.logger.info "Claim #{claim_code} not found. Building..."

          claimable = FutureBuilder.build_aacc_eod_csv(params, claim_code)

          claim = Claim.create do |c|
            c.code = claim_code
            c.name = claim_name
            c.claim_set_id = claim_set.id
            c.size = BigDecimal(params[:ary][34])
            c.point_value = BigDecimal(params[:ary][34])
            c.point_currency_id = currency.id
            c.entity_id = dealing_venue.entity.id
            c.claim_type_id = claim_type.id
            c.claimable = claimable
          end

          if claim.valid?
            claim.save!
          else
            claimable.delete
            raise "Could not build Claim: #{claim.errors}."
          end

          claimable.update(:claimable_id, claim.id)
        else
          # puts "build claim alias"
          begin
            # TODO - WHY? - PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_claim_aliases_on_system_id_and_claim_id"
            ClaimAlias.create! do |a|
              a.system_id = system.id
              a.claim_id = claim.id
              a.code = claim_alias_code
            end
          rescue Exception => e
            Rails.logger.warn "ClaimAlias creation failed for #{claim_alias_code} from #{system.code}."
          end
        end
        claim
      end
    end

    # def self.build_from_abn_pos_csv(params)
    #   system = params[:system]
    #   dealing_venue = params[:dealing_venue]
    #
    #   ary = params[:ary]
    #
    #
    #   currency_code = ary[32]
    #
    #   exchange_code_alias = ary[11]
    #   claim_set_code_alias = ary[12]
    #   maturity_code = ary[16]
    #
    #   claim_set = get_claim_set_abn_pos_csv(params)
    #
    #   claim_alias_code = "#{exchange_code_alias}:#{claim_set_code_alias}:#{maturity_code}"
    #   claim_alias = ClaimAlias.find_by_code(claim_alias_code)
    #
    #   if claim_alias
    #     claim_alias.claim
    #   else
    #     currency = Currency.find_by_code(currency_code) or raise "Could not find Currency #{currency_code} for System #{system.code}."
    #     claim_type = ClaimType.find_by_code('FUT') or raise "Could not find ClaimType Code FUT for System #{system.code}."
    #
    #     maturity_code = L2N.invert[maturity_code[-2, 2]] + maturity_code[2, 2]
    #
    #     claim_code = "#{claim_set.code + maturity_code}"
    #     claim_name = "#{ary[218]}"
    #
    #     # puts "Checking for Claim #{claim_code}..."
    #
    #     claim = Claim.find_by_code(claim_code)
    #
    #     if claim.blank?
    #       # puts "Claim #{claim_code} not found. Building..."
    #
    #       if ary[15] == 'F'
    #         # puts "Building Future..."
    #         claimable = FutureBuilder.build_aacc_eod_csv(params, claim_code)
    #       else
    #         raise "Unknown ClaimType #{params[15]} from System #{system.code}. Skipping."
    #       end
    #
    #       puts '*' * 20
    #       puts claim_code
    #       puts claim_name
    #
    #       # puts "build claim"
    #       claim = Claim.create do |c|
    #         c.code = claim_code
    #         c.name = claim_name
    #         c.claim_set_id = claim_set.id
    #         c.size = BigDecimal(ary[68])
    #         c.point_value = BigDecimal(ary[68])
    #         c.point_currency_id = currency.id
    #         c.entity_id = dealing_venue.entity.id
    #         c.claim_type_id = claim_type.id
    #         c.claimable = claimable
    #       end
    #
    #       if claim.valid?
    #         claim.save!
    #       else
    #         claimable.delete
    #         raise "Could not build Claim: #{claim.errors}."
    #       end
    #
    #       claimable.update(:claimable_id, claim.id)
    #     else
    #       # puts "build claim alias"
    #       begin
    #         # TODO - WHY? - PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_claim_aliases_on_system_id_and_claim_id"
    #         ClaimAlias.create! do |a|
    #           a.system_id = system.id
    #           a.claim_id = claim.id
    #           a.code = claim_alias_code
    #         end
    #       rescue Exception => e
    #         Rails.logger.warn "ClaimAlias creation failed for #{claim_alias_code} from #{system.code}."
    #       end
    #     end
    #     claim
    #   end
    # end

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

    def self.build_from_aacc_fix_42(params)
      system = params[:system]
      dealing_venue = params[:dealing_venue]

      claim_set = get_claim_set_from_aacc_fix_42(params)

      exchange_code = params['207']
      claim_set_code_alias = params['55']
      maturity_code = params['200']

      if params['9039'] =~ /^TRC/
        currency_code = params['9039'].slice(372, 3)
      else
        currency_code = 'UKN'
      end

      claim_alias_code = "#{exchange_code}:#{claim_set_code_alias}:#{maturity_code}"
      # claim_alias = ClaimAlias.find_by_system_id_and_code(system.id, claim_alias_code)
      claim_alias = ClaimAlias.find_by_code(claim_alias_code)

      if claim_alias
        claim_alias.claim
      else
        currency = Currency.find_by_code(currency_code) or raise "Could not find Currency #{currency_code} for System #{system.code}."
        claim_type = ClaimType.find_by_code('FUT') or raise "Could not find ClaimType Code FUT for System #{system.code}."

        maturity_code = L2N.invert[params['200'][-2, 2]] + params['200'][2, 2]

        claim_code = "#{claim_set.code + maturity_code}"
        claim_name = "#{claim_set.code} #{params['200']}"

        # puts "Checking for Claim #{claim_code}..."

        claim = Claim.find_by_code(claim_code)

        if claim.blank?
          # puts "Claim #{claim_code} not found. Building..."

          if params['167'] == 'FUT'
            # puts "Building Future..."
            claimable = FutureBuilder.build(params, claim_code)
          else
            raise "Unknown ClaimType #{params['167']} from System #{system.code}. Skipping."
          end

          # puts "build claim"
          claim = Claim.create do |c|
            c.code = claim_code
            c.name = claim_name
            c.claim_set_id = claim_set.id
            c.size = BigDecimal(params['231'])
            c.point_value = BigDecimal(params['231'])
            c.point_currency_id = currency.id
            c.entity_id = dealing_venue.entity.id
            c.claim_type_id = claim_type.id
            c.claimable = claimable
          end

          if claim.valid?
            claim.save!
          else
            claimable.delete
            raise "Could not build Claim: #{claim.errors}."
          end

          claimable.update_attribute(:claimable_id, claim.id)
        else
          # puts "build claim alias"
          begin
            # TODO - WHY? - PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_claim_aliases_on_system_id_and_claim_id"
            ClaimAlias.create! do |a|
              a.system_id = system.id
              a.claim_id = claim.id
              a.code = claim_alias_code
            end
          rescue Exception => e
            Rails.logger.warn "ClaimAlias creation failed for #{claim_alias_code} from #{system.code}."
          end
        end
        claim
      end
    end

    def self.get_claim_set_fixml(doc)
      exchange_code = doc.css('FIXML TrdCaptRpt Hdr')[0]['SID']
      set_code = doc.css('FIXML TrdCaptRpt Instrmt')[0]['ID']
      code = "#{exchange_code}:#{set_code}"
      claim_set = ClaimSet.find_by_code(code)

      if claim_set.blank?
        claim_set = ClaimSet.create! do |s|
          s.code = code
          s.name = code
        end

        system = System.find_by_code('AACC')

        claim_set_alias = ClaimSetAlias.find_by_system_id_and_code(system.id, code)

        if claim_set_alias.blank?
          ClaimSetAlias.create! do |a|
            a.claim_set_id = claim_set.id
            a.system_id = system.id
            a.code = code
          end
        end
      end

      claim_set
    end

    def self.get_claim_set_aacc_itd_csv(params)
      system = params[:system]
      dealing_venue = params[:dealing_venue]

      claim_set_code_alias = "#{params[:ary][12]}:#{params[:ary][13]}"
      claim_set_alias = ClaimSetAlias.where(system_id: system.id, code: claim_set_code_alias).first

      if claim_set_alias.blank?
        claim_set_code = "#{dealing_venue.code}:#{params[:ary][13]}"
        claim_set = ClaimSet.find_by_code(claim_set_code)
        if claim_set.blank?
          claim_set = ClaimSet.create! do |s|
            s.code = "#{claim_set_code}"
            s.name = "#{params[:ary][33]}"
          end
        end

        claim_set_alias = ClaimSetAlias.create! do |a|
          a.claim_set_id = claim_set.id
          a.system_id = system.id
          a.code = claim_set_code_alias
        end

        claim_set_alias.claim_set
      else
        # If we have a claim_set_alias
        # we must have a claim_set too.
      end

      claim_set_alias.claim_set
    end

    def self.get_claim_set_abn_pos_csv(params)
      system = params[:system]
      dealing_venue = params[:dealing_venue]

      ary = params[:ary]

      claim_set_code_alias = "#{ary[11]}:#{ary[12]}"
      claim_set_alias = ClaimSetAlias.where(system_id: system.id, code: claim_set_code_alias).first

      if claim_set_alias.blank?
        # If we don't have a claim_set_alias
        # assume we don't have a claim_set.
        # This is the hack for the - for now.

        set_code = ary[12]

        claim_set_code = "#{dealing_venue.code}:#{set_code}"

        claim_set = ClaimSet.find_by_code(claim_set_code)

        if claim_set.blank?
          claim_set = ClaimSet.create! do |s|
            s.code = "#{claim_set_code}"
            s.name = "#{claim_set_code} [fixme]"
          end
        end

        claim_set_alias = ClaimSetAlias.create! do |a|
          a.claim_set_id = claim_set.id
          a.system_id = system.id
          a.code = claim_set_code_alias
        end

        claim_set_alias.claim_set
      else
        # If we have a claim_set_alias
        # we must have a claim_set too.
      end

      claim_set_alias.claim_set
    end

    def self.get_claim_set_from_aacc_fix_42(params)
      #
      # All a bit of a hack.
      # claim_set ~ claim_set_alias
      #

      system = params[:system]
      dealing_venue = params[:dealing_venue]

      claim_set_code_alias = "#{params['207']}:#{params['55']}"
      claim_set_alias = ClaimSetAlias.where(system_id: system.id, code: claim_set_code_alias).first

      if claim_set_alias.blank?
        # If we don't have a claim_set_alias
        # assume we don't have a claim_set.
        # This is the hack for the - for now.

        if params['9039'] =~ /^TRC/
          set_code = params['9039'].slice(83, 4).strip
        else
          set_code = params['55']
        end

        claim_set = ClaimSet.create! do |s|
          s.code = "#{dealing_venue.code}:#{set_code}"
          s.name = "#{dealing_venue.code}:#{set_code} [fixme]"
        end

        claim_set_alias = ClaimSetAlias.create! do |a|
          a.claim_set_id = claim_set.id
          a.system_id = system.id
          a.code = claim_set_code_alias
        end

        claim_set_alias.claim_set
      else
        # If we have a claim_set_alias
        # we must have a claim_set too.
      end

      claim_set_alias.claim_set
    end

    def self.build_from_cme_fixml_itd(fixml)
      doc = Nokogiri::XML(fixml)
      claim_code = cme_fixml_claim_code_mapper(doc)
      clearing_code = doc.css('FIXML TrdCaptRpt Instrmt').first['ID'] # ED, C
      system = System.find_by_code('CME_FIX_ITD')
      entity_code = doc.css('FIXML TrdCaptRpt Instrmt').first['Exch']
      entity = EntityAlias.find_by_system_id_and_code(system.id, entity_code)
      size = doc.css('FIXML TrdCaptRpt Instrmt').first['UOMQty']
      size_price_divisor = doc.css('FIXML TrdCaptRpt Instrmt').first['PxUOMQty']
      point_value = BigDecimal(size / size_price_divisor, 8)
      claim_type_code = doc.css('FIXML TrdCaptRpt Instrmt').first['SecTyp']
      claim_type = ClaimType.find_by_code(claim_type_code)
      claim_sub_type_code = doc.css('FIXML TrdCaptRpt Instrmt').first['SubTyp']
      claim_sub_type = ClaimSubType.find_by_code(claim_sub_type_code)
      # claim_multiplier = BigDecimal(doc.css('FIXML TrdCaptRpt Instrmt').first['Mult'])

      claim_set = ClaimSet.find_by_code(clearing_code)

      if claim_set.blank?
        claim_set = ClaimSet.create! do |cs|
          cs.code = clearing_code
          cs.name = "#{entity_code} #{clearing_code}"
        end
      end

      claim = Claim.find_by_code(claim_code)

      if claim.blank?
        # puts "building claim #{claim_code}"
        claim = Claim.create! do |c|
          c.claim_set = claim_set
          c.entity_id = entity.id
          c.code = claim_code
          c.name = "#{entity_code} #{claim_code}"
          c.size = size
          c.claim_type = claim_type
          c.claim_sub_type = claim_sub_type unless claim_sub_type.blank?
          c.point_value = point_value
          c.price_ccy = doc.css('FIXML TrdCaptRpt Instrmt').first['PxQteCcy']
        end
      else
        # puts "found claim #{claim_code}"
      end
      # puts claim.valid?
      # puts claim.errors.keys
      claim
    end

    # def self.cme_fixml_claim_code_mapper(doc)
    #   # There is probably a better way to do this
    #   # using regex matching and substitution.
    #   given_code = doc.css('FIXML TrdCaptRpt Instrmt').first['Sym'] # GEM4, ZCH4
    #   clearing_code = doc.css('FIXML TrdCaptRpt Instrmt').first['ID'] # ED, C
    #   if given_code =~ /-/
    #     # spread symbol
    #     given_codes = given_code.split(/-/)
    #     built_codes = []
    #     given_codes.each do |gc|
    #       delivery_code = gc.split(//).last(2).join
    #       built_codes << clearing_code + delivery_code
    #     end
    #     code = built_codes.join('-')
    #   else
    #     delivery_code = given_code.split(//).last(2).join
    #     code = clearing_code + delivery_code
    #   end
    #   code
    # end


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

    def self.build_from_cme_eod(params)
      system = System.find_by_code('CMEsys')

      size = BigDecimal(params['FIXML']['TrdCaptRpt']['Instrmt']['UOMQty'], 8)
      point_value = BigDecimal(params['FIXML']['TrdCaptRpt']['Instrmt']['Mult'], 8)

      entity_code = params['FIXML']['TrdCaptRpt']['Instrmt']['Exch']
      entity_alias = EntityAlias.find_by_system_id_and_code(system.id, entity_code)
      entity = entity_alias.entity

      clearing_code = params['FIXML']['TrdCaptRpt']['Instrmt']['ID']
      clearing_desc = params['FIXML']['TrdCaptRpt']['Instrmt']['Desc']

      claim_code = cme_fixml_claim_code_mapper_eod(params)
      claim_type_code = params['FIXML']['TrdCaptRpt']['Instrmt']['SecTyp']
      claim_type = ClaimType.find_by_code(claim_type_code)
      claim_sub_type_code = params['FIXML']['TrdCaptRpt']['Instrmt']['SubTyp']
      claim_sub_type = ClaimSubType.find_by_code(claim_sub_type_code)

      currency_code = params['FIXML']['TrdCaptRpt']['Instrmt']['PxQteCcy']

      claim_set_code = "#{entity_code}:#{clearing_code}"

      claim_set = ClaimSet.find_by_code(claim_set_code)

      if claim_set.blank?
        claim_set = ClaimSet.create! do |cs|
          cs.code = claim_set_code
          cs.name = "#{entity_code}:#{clearing_desc}"
        end
      end

      claim_code = "#{entity_code}:#{claim_code}"

      claim = Claim.find_by_code(claim_code)

      if claim.blank?
        # puts "building claimable #{claim_code}"
        if claim_type_code == 'FUT'
          # puts "Building Future..."
          claimable = FutureBuilder.build_cme_eod(params, claim_code)
        else
          raise "Unknown ClaimType #{claim_type_code} from System #{system.code}. Skipping."
        end

        point_value = point_value / 100 if entity_code =~ /CBT/ and clearing_code =~ /S|C|W|KW/

        claim = Claim.create! do |c|
          c.claimable = claimable
          c.claimable_type = 'Future'
          c.claim_set = claim_set
          c.entity_id = entity.id
          c.code = claim_code
          c.name = claim_code
          c.size = size
          c.claim_type = claim_type
          c.claim_sub_type = claim_sub_type unless claim_sub_type.blank?
          c.point_value = point_value
          c.point_currency_id = Currency.find_by_code(currency_code).id
        end

        claimable.update_attribute(:claimable_id, claim.id)
      else
        # puts "found claim #{claim_code}"
      end
      # puts '*' * 100
      # puts claim.valid?
      # puts claim.errors.keys
      # puts claim.entity.code

      claim
    end

    def self.cme_fixml_claim_code_mapper(doc)
      # There is probably a better way to do this
      # using regex matching and substitution.
      given_code = doc.css('FIXML TrdCaptRpt Instrmt').first['Sym'] # GEM4, ZCH4
      clearing_code = doc.css('FIXML TrdCaptRpt Instrmt').first['ID'] # ED, C
      if given_code =~ /-/
        # spread symbol
        given_codes = given_code.split(/-/)
        built_codes = []
        given_codes.each do |gc|
          delivery_code = gc.split(//).last(2).join
          built_codes << clearing_code + delivery_code
        end
        code = built_codes.join('-')
      else
        delivery_code = given_code.split(//).last(2).join
        code = clearing_code + delivery_code
      end
      code
    end

    def self.cme_fixml_claim_code_mapper_eod(params)
      claim_set_code = params['FIXML']['TrdCaptRpt']['Instrmt']['ID']
      year = params['FIXML']['TrdCaptRpt']['Instrmt']['MMY'][0..3]
      month = params['FIXML']['TrdCaptRpt']['Instrmt']['MMY'][4..5]
      delivery_code = N2L[month] + year[2..3]
      claim_set_code + delivery_code
    end

    def self.future_given_code(code)

      #
      # Build CBT:H09 from CBT:H19
      #

      ActiveRecord::Base.transaction do
        claim_set_code = code[0..4]
        claim_set_code_with_month = code[0..5]
        puts code
        puts claim_set_code
        claim_set = ClaimSet.find_by_code(claim_set_code)
        existing_claim = claim_set.claims.where("code LIKE :query", query: "%#{claim_set_code_with_month}%").order(:id).last
        attrs = existing_claim.attributes.with_indifferent_access
        attrs = attrs.except(:id, :claimable_id, :created_at, :updated_at)

        year_code = code[-2..-1]
        mnth_code = code[5]
        mnth_code = Builders::ClaimBuilder::L2N[mnth_code]
        expires_on = "20#{year_code}-#{mnth_code}-20" # arbitrary day of the month

        attrs[:code] = code
        existing_year_code = existing_claim.code[-2..-1]
        attrs[:name] = attrs[:name].sub(existing_year_code, year_code)

        future = Future.create! do |f|
          f.code = attrs[:code]
          f.expires_on = expires_on
        end

        claim = Claim.create(attrs)
        claim.claimable = future
        claim.save!

        future.update_attribute(:claimable_id, claim.id)

        claim
      rescue Exception => e
        msg = e.message
        puts msg
        Rails.logger.warn msg
      end
    end

    def self.get_claim_set_ghf_csv(params)
      system = params[:system]
      dealing_venue = params[:dealing_venue]

      claim_set_code_alias = "#{params[:ary][31]}:#{params[:ary][4]}"
      claim_set_alias = ClaimSetAlias.where(system_id: system.id, code: claim_set_code_alias).first

      if claim_set_alias.blank?
        claim_set_code = claim_set_code_alias
        claim_set = ClaimSet.find_by_code(claim_set_code)
        if claim_set.blank?
          claim_set = ClaimSet.create! do |s|
            s.code = "#{claim_set_code}"
            s.name = s.code
          end
        end

        claim_set_alias = ClaimSetAlias.create! do |a|
          a.claim_set_id = claim_set.id
          a.system_id = system.id
          a.code = claim_set_code_alias
        end

        claim_set_alias.claim_set
      else
        # If we have a claim_set_alias
        # we must have a claim_set too.
      end

      claim_set_alias.claim_set
    end

    def self.build_claim_from_ghf_csv(params)
      system = params[:system]
      dealing_venue = params[:dealing_venue]

      currency_code = params[:ary][17]

      exchange_code_alias = params[:ary][31]
      claim_set_code_alias = params[:ary][4]
      maturity_code = params[:ary][5]

      claim_set = get_claim_set_ghf_csv(params)

      claim_alias_code = "#{exchange_code_alias}:#{claim_set_code_alias}:#{maturity_code}"
      claim_alias = ClaimAlias.find_by_code(claim_alias_code)

      if claim_alias
        claim_alias.claim
      else
        currency = Currency.find_by_code(currency_code) or raise "Could not find Currency #{currency_code} for System #{system.code}."
        claim_type = ClaimType.find_by_code('FUT') or raise "Could not find ClaimType Code FUT for System #{system.code}."

        maturity_code = claim_alias_code.split(':')[2]
        mth, year = maturity_code.split('-')
        mth = mth.capitalize
        maturity_code = N2L[M2N[mth]] + year

        maturity_name = claim_alias_code.split(':')[2]

        claim_code = "#{claim_set.code}#{maturity_code}"
        claim_name = "#{claim_alias_code.split(':')[1]} #{maturity_name}"

        Rails.logger.info "Checking for Claim #{claim_code}..."

        claim = Claim.find_by_code(claim_code)

        if claim.blank?
          Rails.logger.info "Claim #{claim_code} not found. Building..."

          claimable = FutureBuilder.build_ghf_eod_csv(params, claim_code)

          claim = Claim.create do |c|
            c.code = claim_code
            c.name = claim_name
            c.claim_set_id = claim_set.id
            c.size = BigDecimal(params[:ary][7])
            c.point_value = BigDecimal(params[:ary][7])  # todo <<<<<<<<<<<<<<<< could be a problem >>>>>>>>>>>>>>>>
            c.point_currency_id = currency.id
            c.entity_id = dealing_venue.entity.id
            c.claim_type_id = claim_type.id
            c.claimable = claimable
          end

          if claim.valid?
            claim.save!
          else
            claimable.delete
            raise "Could not build Claim: #{claim.errors}."
          end

          claimable.update_attribute(:claimable_id, claim.id)
        else
          # puts "build claim alias"
          begin
            # TODO - WHY? - PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_claim_aliases_on_system_id_and_claim_id"
            ClaimAlias.create! do |a|
              a.system_id = system.id
              a.claim_id = claim.id
              a.code = claim_alias_code
            end
          rescue Exception => e
            Rails.logger.warn "ClaimAlias creation failed for #{claim_alias_code} from #{system.code}."
          end
        end
        claim
      end
    end
  end

end
