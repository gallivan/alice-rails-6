RSpec.describe Account, type: :model do

  #
  # Two fills and one day with one lot netting.
  #

  describe "#handle_fill sld one CBT:CU20 and bot one CBT:CU20 - one day two fills one netting" do

    before(:all) do
      puts "preparation begun."

      DatabaseCleaner.strategy = :truncation
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
      FactoryBot.create(:ledger_entry_type_adj)
      FactoryBot.create(:ledger_entry_type_chg)
      FactoryBot.create(:ledger_entry_type_leg)
      FactoryBot.create(:ledger_entry_type_ote)
      FactoryBot.create(:ledger_entry_type_liq)
      FactoryBot.create(:ledger_entry_type_cshact)
      FactoryBot.create(:ledger_entry_type_pnlfut)

      puts "preparation ended."

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
      name = "#{Rails.root}/etc/data/cme/rspec/CBT:CU20:00877:2020-08-28:35626595912.xml"
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

      # post Claim mark

      params = {
        system_id: @account.deal_leg_fills.last.system.id,
        posted_on: @account.deal_leg_fills.last.posted_on,
        mark: 344.00,
        approved: false
      }
      claim.post_claim_mark(params)

      # post USD mark

      params = {
        currency_id: Currency.usd.id,
        posted_on: @account.deal_leg_fills.last.posted_on,
        mark: 1.0
      }
      CurrencyMark.post_mark(params)

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

      # run eod

      @account.eod_for(@account.deal_leg_fills.last.posted_on)
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    context "when account 00877 executes CBT:CU20 bot and sld" do

      it "then account with code '00877' should exist" do
        expect(@account.code).to eql('00877')
      end

      it "and one fill is found" do
        expect(@account.deal_leg_fills.count).to eq(2)
      end

      it "and the fill has appropriate attributes" do
        expect(@account.deal_leg_fills.last.system.code).to eq('CMEsys')
        expect(@account.deal_leg_fills.last.dealing_venue.code).to eq('CBT')
        expect(@account.deal_leg_fills.last.dealing_venue_done_id).to eq('70507:M:4191576TN0001322 106089')
        expect(@account.deal_leg_fills.last.claim.code).to eq('CBT:CU20')
        expect(@account.deal_leg_fills.last.done).to eq(-1)
        expect(@account.deal_leg_fills.last.price).to eq(344.25)
        expect(@account.deal_leg_fills.last.price_traded).to eq('344-1/4')
        expect(@account.deal_leg_fills.last.posted_on).to eq(Date.parse('2020-08-28'))
        expect(@account.deal_leg_fills.last.traded_on).to eq(Date.parse('2020-08-28'))
        expect(@account.deal_leg_fills.last.kind).to eq('DATA')
      end

      it "and one position is found" do
        expect(@account.positions.count).to eq(1)
      end

      it "and the position has appropriate attributes" do
        expect(@account.positions.last.posted_on).to eq(Date.parse('2020-08-28'))
        expect(@account.positions.last.traded_on).to eq(Date.parse('2020-08-28'))
        expect(@account.positions.last.price).to eq(344.25)
        expect(@account.positions.last.price_traded).to eq('344-1/4')
        expect(@account.positions.last.mark).to eq(344.25)
        expect(@account.positions.last.bot).to eq(0)
        expect(@account.positions.last.sld).to eq(0)
        expect(@account.positions.last.bot_off).to eq(1)
        expect(@account.positions.last.sld_off).to eq(1)
        expect(@account.positions.last.net).to eq(0)
        expect(@account.positions.last.currency.code).to eq('USD')
      end

      it "and one statement position is found" do
        expect(@account.statement_positions.count).to eq(0)
      end

      # by virtue of the bot vs sld...

      it "and one net position is found" do
        expect(@account.position_nettings.count).to eq(1)
      end

      it "and appropriate charges are charged" do
        expect(Charge.count).to eq(1)
        charge = Charge.last
        expect(charge.amount).to eq(BigDecimal(-0.40, 8))
        expect(charge.currency.code).to eq('USD')
      end

      it "and 2 money lines" do
        expect(@account.money_lines.count).to eq(2)
      end

      it "and appropriate USD SEGN money line values exist" do
        cid = Currency.usd.id
        sid = Segregation.find_by_code('SEGN').id

        money_line = @account.money_lines.currency(cid).segregation(sid).first

        expect(money_line.posted_on).to eq(Date.parse('2020-08-28'))
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.40)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-0.40, 8))
        expect(money_line.open_trade_equity).to eq(0.00)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-0.40, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-0.40, 8))
      end

      it "and appropriate USD SEGB money line values exist" do
        cid = Currency.usd.id
        sid = Segregation.find_by_code('SEGB').id

        money_line = @account.money_lines.currency(cid).segregation(sid).first

        expect(money_line.posted_on).to eq(Date.parse('2020-08-28'))
        expect(money_line.kind).to eq('BASE')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(BigDecimal(-0.40, 8))
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-0.40, 8))
        expect(money_line.open_trade_equity).to eq(BigDecimal(0.00, 8))
        expect(money_line.cash_account_balance).to eq(BigDecimal(-0.40, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-0.40, 8))
      end

    end
  end

end