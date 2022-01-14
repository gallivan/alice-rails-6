RSpec.describe Account, type: :model do

  #
  # Two fills and one day with one lot netting.
  # No fills next day. Change in settlement.
  #

  describe "#handle_fills CBT:CU20 bot and sld - two days two fills one netting" do

    before(:all) do
      puts "preparing begun."

      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start

      Rails.cache.clear
      
      acct_code = '00877'

      firm = FactoryBot.create(:entity_emm)

      FactoryBot.create(:account_regular, entity: firm, code: acct_code, name: "#{firm.name} account #{acct_code}")

      find_or_create(:entity_cbt)

      FactoryBot.create(:system_cme)

      FactoryBot.create(:entity_alias_cme_cbt)
      FactoryBot.create(:dealing_venue_cbt)
      FactoryBot.create(:dealing_venue_alias_cmesys_cbt)
      FactoryBot.create(:claim_type_future)
      FactoryBot.create(:position_status_opn)
      FactoryBot.create(:position_status_clo)
      FactoryBot.create(:adjustment_type_fee)

      FactoryBot.create(:position_netting_type_sch)
      FactoryBot.create(:position_netting_type_day)
      FactoryBot.create(:position_netting_type_ovr)

      FactoryBot.create(:chargeable_type_srv)
      FactoryBot.create(:chargeable_type_exg)

      FactoryBot.create(:currency_usd)

      FactoryBot.create(:segregation_segn)
      FactoryBot.create(:segregation_base)

      FactoryBot.create(:journal_sole)
      FactoryBot.create(:journal_entry_type_adj)
      FactoryBot.create(:journal_entry_type_fee)
      FactoryBot.create(:journal_entry_type_ote)
      FactoryBot.create(:journal_entry_type_pnl)

      FactoryBot.create(:ledger_sole)
      FactoryBot.create(:ledger_entry_type_beg)
      FactoryBot.create(:ledger_entry_type_adj)
      FactoryBot.create(:ledger_entry_type_chg)
      FactoryBot.create(:ledger_entry_type_leg)
      FactoryBot.create(:ledger_entry_type_ote)
      FactoryBot.create(:ledger_entry_type_liq)
      FactoryBot.create(:ledger_entry_type_cshact)
      FactoryBot.create(:ledger_entry_type_pnlfut)

      puts "preparing ended."

      @day_one = Date.parse('2020-08-28')
      @day_two = Date.parse('2020-09-01') 

      # bot

      # <?xml version="1.0" encoding="UTF-8"?>
      # <FIXML>
      #   <TrdCaptRpt RptID="35626654109" TrdTyp="0" TrdSubTyp="7" ExecID="70507:M:4192131TN0001335" TrdDt="2020-08-28"
      #               BizDt="2020-08-28" MLegRptTyp="2" MtchStat="0" MsgEvtSrc="REG" TrdID="106107" LastQty="1" LastPx="3.4425"
      #               TxnTm="2020-08-28T10:51:04-05:00" SettlCcy="USD" SettlDt="2020-09-14" OrigTrdID="1741C49392D1201D1708A9E"
      #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
      #     <Instrmt ID="C" Desc="CORN FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="202009" MatDt="2020-09-14" Mult="5000" Exch="CBT"
      #              UOM="Bu" UOMQty="5000" PxUOM="BU" PxUOMQty="1" ValMeth="FUT" Fctr="1" PxQteCcy="USD"/>
      #     <Amt Typ="TVAR" Amt="87.5" Ccy="USD"/>
      #     <RptSide Side="1" ClOrdID="70222871873080" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0"
      #              AgrsrInd="Y">
      #       <Pty ID="CME" R="21"></Pty>
      #       <Pty ID="353" R="4"></Pty>
      #       <Pty ID="CBT" R="22"></Pty>
      #       <Pty ID="330" R="1"></Pty>
      #       <Pty ID="00877" R="24">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="3E3L" R="12"></Pty>
      #       <Pty ID="330B" R="38">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="330" R="7"></Pty>
      #       <RegTrdID ID="FECC1741C49392D1201D1708AA4" Src="1010000023" Typ="0" Evnt="2"/>
      #     </RptSide>
      #   </TrdCaptRpt>
      # </FIXML>

      # pick
      name = "#{Rails.root}/etc/data/cme/rspec/CBT:CU20:00877:2020-08-28:35626654109.xml"
      fix = File.open(name).read
      # pack
      hash = Workers::Packer.new.cme_fixml_to_hash(fix)
      # book
      norm = Workers::Normalizer.normalize_cme_eod(hash)
      booker_report = Workers::Booker.new.build_report(norm)
      norm[:booker_report_id] = booker_report.id
      @account = Account.find(norm[:account_id])
      @account.handle_fill(norm)
      booker_report.update!(fate: 'DONE')

      # sld

      # <?xml version="1.0" encoding="UTF-8"?>
      # <FIXML>
      #   <TrdCaptRpt RptID="35646991523" TrdTyp="0" TrdSubTyp="7" ExecID="70508:M:1186334TN0000147" TrdDt="2020-09-01"
      #               BizDt="2020-09-01" MLegRptTyp="2" MtchStat="0" MsgEvtSrc="REG" TrdID="100901" LastQty="2" LastPx="3.485"
      #               TxnTm="2020-09-01T08:39:01-05:00" SettlCcy="USD" SettlDt="2020-09-14" OrigTrdID="1744055AC2C1202D4F8A30"
      #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
      #     <Instrmt ID="C" Desc="CORN FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="202009" MatDt="2020-09-14" Mult="5000" Exch="CBT"
      #              UOM="Bu" UOMQty="5000" PxUOM="BU" PxUOMQty="1" ValMeth="FUT" Fctr="1" PxQteCcy="USD"/>
      #     <Amt Typ="TVAR" Amt="-100" Ccy="USD"/>
      #     <RptSide Side="2" ClOrdID="70123477081081" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0"
      #              AgrsrInd="N">
      #       <Pty ID="CME" R="21"></Pty>
      #       <Pty ID="353" R="4"></Pty>
      #       <Pty ID="CBT" R="22"></Pty>
      #       <Pty ID="330" R="1"></Pty>
      #       <Pty ID="00877" R="24">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="3E3L" R="12"></Pty>
      #       <Pty ID="330B" R="38">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="330" R="7"></Pty>
      #       <RegTrdID ID="FECC1744055AC2C1202D4F8A4E" Src="1010000023" Typ="0" Evnt="2"/>
      #     </RptSide>
      #   </TrdCaptRpt>
      # </FIXML>

      # pick
      name = "#{Rails.root}/etc/data/cme/rspec/CBT:CU20:00877:2020-09-01:35646991523.xml"
      fix = File.open(name).read
      # pack
      hash = Workers::Packer.new.cme_fixml_to_hash(fix)
      # book
      norm = Workers::Normalizer.normalize_cme_eod(hash)
      booker_report = Workers::Booker.new.build_report(norm)
      norm[:booker_report_id] = booker_report.id
      @account = Account.find(norm[:account_id])
      @account.handle_fill(norm)
      booker_report.update!(fate: 'DONE')

      claim = @account.deal_leg_fills.last.claim

      # post Claim marks

      [
          {
              system_id: @account.deal_leg_fills.last.system.id,
              posted_on: @day_one,
              mark: 337.00,
              approved: false
          },
          {
              system_id: @account.deal_leg_fills.last.system.id,
              posted_on: @day_two,
              mark: 338.50,
              approved: false
          },
      ].each { |p| claim.post_claim_mark(p) }

      # post USD marks

      [
          {
              currency_id: Currency.usd.id,
              posted_on: @day_one,
              mark: 1.0
          },
          {
              currency_id: Currency.usd.id,
              posted_on: @day_two,
              mark: 1.0
          }
      ].each { |p| CurrencyMark.post_mark(p) }

      # create Chargeable

      params = {
          chargeable_type_id: ChargeableType.find_by_code('EXG').id,
          claim_set_id: claim.claim_set.id,
          currency_id: Currency.usd.id,
          amount: 0.20,
          begun_on: 1.year.ago,
          ended_on: 1.year.from_now
      }
      Chargeable.create!(params)

      # run eod Thursday

      @account.eod_for(@day_one)

      # run eod Friday

      @account.eod_for(@day_two)
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    context "when account 00877 executes CBT:CU20 on 2020-08-28 and 2020-09-01, bot 1 then sld 2" do

      ##############
      # 2020-08-28 #
      ##############

      it "then account with code '00877' should exist" do
        expect(@account.code).to eql('00877')
      end

      it "and 2 fills are found posted on 2020-08-28" do
        expect(@account.deal_leg_fills.posted_on(@day_one).count).to eq(1)
      end

      it "and the BOT fill has appropriate attributes" do
        bot_fill = @account.deal_leg_fills.order(:id).first

        expect(bot_fill.system.code).to eq('CMEsys')
        expect(bot_fill.dealing_venue.code).to eq('CBT')
        expect(bot_fill.dealing_venue_done_id).to eq('70507:M:4192131TN0001335 106107')
        expect(bot_fill.claim.code).to eq('CBT:CU20')
        expect(bot_fill.done).to eq(+1)
        expect(bot_fill.price).to eq(344.25)
        expect(bot_fill.price_traded).to eq('344-1/4')
        expect(bot_fill.posted_on).to eq(@day_one)
        expect(bot_fill.traded_on).to eq(@day_one)
        expect(bot_fill.kind).to eq('DATA')
      end

      it "and the SLD fill has appropriate attributes" do
        sld_fill = @account.deal_leg_fills.order(:id).last

        expect(sld_fill.system.code).to eq('CMEsys')
        expect(sld_fill.dealing_venue.code).to eq('CBT')
        expect(sld_fill.dealing_venue_done_id).to eq('70508:M:1186334TN0000147 100901')
        expect(sld_fill.claim.code).to eq('CBT:CU20')
        expect(sld_fill.done).to eq(-2)
        expect(sld_fill.price).to eq(348.50)
        expect(sld_fill.price_traded).to eq('348-1/2')
        expect(sld_fill.posted_on).to eq(@day_two)
        expect(sld_fill.traded_on).to eq(@day_two)
        expect(sld_fill.kind).to eq('DATA')
      end

      it "and one position is found posted on 2020-08-28" do
        expect(@account.positions.posted_on(@day_one).count).to eq(1)
      end

      it "and the position posted on 2020-08-28 has appropriate attributes" do
        position = @account.positions.posted_on(@day_one).first

        expect(position.posted_on).to eq(@day_one)
        expect(position.traded_on).to eq(@day_one)
        expect(position.price).to eq(344.25)
        expect(position.price_traded).to eq('344-1/4')
        expect(position.mark).to eq(337.00)
        expect(position.bot).to eq(0)
        expect(position.sld).to eq(0)
        expect(position.bot_off).to eq(1)
        expect(position.sld_off).to eq(0)
        expect(position.net).to eq(0)
        expect(position.currency.code).to eq('USD')
      end

      it "and one statement position is found stated on 2020-08-28" do
        expect(@account.statement_positions.stated_on(@day_one).count).to eq(1)
      end

      it "and the statement position has appropriate attributes" do
        statement_position = @account.statement_positions.stated_on(@day_one).first

        expect(statement_position.stated_on).to eq(@day_one)
        expect(statement_position.posted_on).to eq(@day_one)
        expect(statement_position.traded_on).to eq(@day_one)
        expect(statement_position.price).to eq(344.25)
        expect(statement_position.mark).to eq(337.00)
        expect(statement_position.bot).to eq(1)
        expect(statement_position.sld).to eq(0)
        expect(statement_position.net).to eq(+1)
        expect(statement_position.currency_code).to eq('USD')
      end

      # by virtue of the bot vs sld...

      it "and one net position is found" do
        expect(@account.position_nettings.count).to eq(1)
      end

      it "and appropriate charges are charged" do
        expect(Charge.count).to eq(2)
        charge = Charge.last
        expect(charge.amount).to eq(BigDecimal(-0.40, 8))
        expect(charge.currency.code).to eq('USD')
      end

      it "and 2 money lines - for day 1" do
        expect(@account.money_lines.posted_on(@day_one).count).to eq(2)
      end

      it "and appropriate USD SEGN money line values exist - for day 1" do
        cid = Currency.usd.id
        sid = Segregation.find_by_code('SEGN').id

        money_line = @account.money_lines.currency(cid).segregation(sid).posted_on(@day_one).first

        expect(money_line.posted_on).to eq(@day_one)
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.20)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-0.20, 8))
        expect(money_line.open_trade_equity).to eq(-362.50)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-362.70, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-362.70, 8))
      end

      it "and appropriate USD BASE money line values exist - for day 1" do
        cid = Currency.usd.id
        sid = Segregation.find_by_code('SEGB').id

        money_line = @account.money_lines.currency(cid).segregation(sid).posted_on(@day_one).first

        expect(money_line.posted_on).to eq(@day_one)
        expect(money_line.kind).to eq('BASE')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.20)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-0.20, 8))
        expect(money_line.open_trade_equity).to eq(-362.50)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-362.70, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-362.70, 8))
      end

      ##############
      # 2020-09-01 #
      ##############

      it "and 2 money lines - for day 2" do
        expect(@account.money_lines.posted_on(@day_two).count).to eq(2)
      end

      it "and appropriate USD SEGN money line values exist - for day 2" do
        cid = Currency.usd.id
        sid = Segregation.find_by_code('SEGN').id

        money_line = @account.money_lines.currency(cid).segregation(sid).posted_on(@day_two).first

        expect(money_line.posted_on).to eq(@day_two)
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(BigDecimal(-0.20, 8))
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.40)
        expect(money_line.pnl_futures).to eq(212.50)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(211.90, 8))
        expect(money_line.open_trade_equity).to eq(500.0)
        expect(money_line.cash_account_balance).to eq(BigDecimal(711.90, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(711.90, 8))
      end

      it "and appropriate USD BASE money line values exist - for day 2" do
        cid = Currency.usd.id
        sid = Segregation.find_by_code('SEGB').id

        money_line = @account.money_lines.currency(cid).segregation(sid).posted_on(@day_two).first

        expect(money_line.posted_on).to eq(@day_two)
        expect(money_line.kind).to eq('BASE')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(BigDecimal(-0.20, 8))
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.40)
        expect(money_line.pnl_futures).to eq(212.50)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(211.90, 8))
        expect(money_line.open_trade_equity).to eq(500.0)
        expect(money_line.cash_account_balance).to eq(BigDecimal(711.90, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(711.90, 8))
      end

    end
  end

end
