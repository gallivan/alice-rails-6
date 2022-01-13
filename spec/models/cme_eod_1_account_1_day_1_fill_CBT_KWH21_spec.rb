RSpec.describe Account, type: :model do

  #
  # One fill and one day with no netting.
  #

  describe "#handle_fill CBT:KWH21:00005:21937832663 - one day one fill" do

    before(:all) do
      puts "preparation begun."

      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start

      Rails.cache.clear

      acct_code = '00005'

      firm = FactoryBot.create(:entity_emm)

      FactoryBot.create(:account_regular, entity: firm, code: acct_code, name: firm.name + " account #{acct_code}")

      FactoryBot.create(:entity_cbt)
      FactoryBot.create(:system_cme)

      FactoryBot.create(:entity_alias_cme_cbt)
      FactoryBot.create(:dealing_venue_cbt)
      FactoryBot.create(:dealing_venue_alias_cmesys_cbt)
      FactoryBot.create(:claim_type_future)
      FactoryBot.create(:position_status_opn)
      FactoryBot.create(:adjustment_type_fee)

      FactoryBot.create(:currency_usd)

      FactoryBot.create(:segregation_segn)
      FactoryBot.create(:segregation_base)

      FactoryBot.create(:chargeable_type_srv)
      FactoryBot.create(:chargeable_type_exg)

      FactoryBot.create(:journal_sole)
      FactoryBot.create(:journal_entry_type_adj)
      FactoryBot.create(:journal_entry_type_ote)
      FactoryBot.create(:journal_entry_type_fee)

      FactoryBot.create(:ledger_sole)
      FactoryBot.create(:ledger_entry_type_adj)
      FactoryBot.create(:ledger_entry_type_chg)
      FactoryBot.create(:ledger_entry_type_leg)
      FactoryBot.create(:ledger_entry_type_ote)
      FactoryBot.create(:ledger_entry_type_liq)
      FactoryBot.create(:ledger_entry_type_cshact)

      puts "preparation ended."

      # <?xml version="1.0" encoding="UTF-8"?>
      # <FIXML>
      #   <TrdCaptRpt RptID="36745736396" TrdTyp="0" TrdSubTyp="7" ExecID="70524:M:2051265TN0000004" TrdDt="2020-12-23"
      #               BizDt="2020-12-23" MLegRptTyp="2" MtchStat="0" MsgEvtSrc="REG" TrdID="100015" LastQty="5" LastPx="5.7925"
      #               TxnTm="2020-12-22T19:01:39-06:00" SettlCcy="USD" SettlDt="2021-03-12" OrigTrdID="1768154D71B1202D3FBD02"
      #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
      #     <Instrmt ID="KW" Desc="KC  HRW WHEAT FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="202103" MatDt="2021-03-12" Mult="5000"
      #              Exch="CBT" UOM="Bu" UOMQty="5000" PxUOM="BU" PxUOMQty="1" ValMeth="FUT" Fctr="1" PxQteCcy="USD"/>
      #     <Amt Typ="TVAR" Amt="-2187.5" Ccy="USD"/>
      #     <RptSide Side="2" ClOrdID="70092984536006" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0"
      #              AgrsrInd="Y">
      #       <Pty ID="CME" R="21"></Pty>
      #       <Pty ID="353" R="4"></Pty>
      #       <Pty ID="CBT" R="22"></Pty>
      #       <Pty ID="330" R="1"></Pty>
      #       <Pty ID="00005" R="24">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="3E3L" R="12"></Pty>
      #       <Pty ID="330B" R="38">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="330" R="7"></Pty>
      #       <RegTrdID ID="FECC1768154D71B1202D3FBD05" Src="1010000023" Typ="0" Evnt="2"/>
      #     </RptSide>
      #   </TrdCaptRpt>
      # </FIXML>

      # get execution report
      name = "#{Rails.root}/etc/data/cme/rspec/CBT:KH21:00005:2020-12-23:36745736396.xml"
      fix = File.open(name).read

      # pack
      hash = Workers::Packer.new.cme_fixml_to_hash(fix)

      # book
      norm = Workers::Normalizer.normalize_cme_eod(hash)
      booker_report = Workers::Booker.new.build_report(norm)
      norm[:booker_report_id] = booker_report.id
      @account = Account.find(norm[:account_id])
      @account.handle_fill(norm)
      booker_report.update_attributes!(fate: 'DONE')

      # create adjustment
      adjustment_type = AdjustmentType.find_by_code('FEE')
      segregation = Segregation.find_by_code('SEGN')
      params = {
        posted_on: @account.deal_leg_fills.last.posted_on.to_s,
        account_id: @account.id,
        currency_id: Currency.usd.id,
        segregation_id: segregation.id,
        adjustment_type_id: adjustment_type.id,
        amount: -98,
        memo: 'testing'
      }
      Builders::AdjustmentBuilder.build(params)

      claim = @account.deal_leg_fills.last.claim

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

      # post claim mark

      params = {
        system_id: @account.deal_leg_fills.last.system.id,
        posted_on: @account.deal_leg_fills.last.posted_on,
        mark: 579.00,
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

      # run eod

      @account.eod_for(@account.deal_leg_fills.last.posted_on)
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    context "when account 00005 executes CBT:KH21 via CME EOD with id 36745736396" do

      it "then account with code '00005' should exist" do
        expect(@account.code).to eql('00005')
      end

      it "and one fill is found" do
        expect(@account.deal_leg_fills.count).to eq(1)
      end

      it "and the fill has appropriate attributes" do
        expect(@account.deal_leg_fills.last.system.code).to eq('CMEsys')
        expect(@account.deal_leg_fills.last.dealing_venue.code).to eq('CBT')
        expect(@account.deal_leg_fills.last.dealing_venue_done_id).to eq('70524:M:2051265TN0000004 100015')
        expect(@account.deal_leg_fills.last.claim.code).to eq('CBT:KWH21')
        expect(@account.deal_leg_fills.last.done).to eq(-5)
        expect(@account.deal_leg_fills.last.price).to eq(579.25)
        expect(@account.deal_leg_fills.last.price_traded).to eq('579-1/4')
        expect(@account.deal_leg_fills.last.posted_on).to eq(Date.parse('2020-12-23'))
        expect(@account.deal_leg_fills.last.traded_on).to eq(Date.parse('2020-12-23'))
        expect(@account.deal_leg_fills.last.kind).to eq('DATA')
      end

      it "and one position is found" do
        expect(@account.positions.count).to eq(1)
      end

      it "and the position has appropriate attributes" do
        expect(@account.positions.last.posted_on).to eq(Date.parse('2020-12-23'))
        expect(@account.positions.last.traded_on).to eq(Date.parse('2020-12-23'))
        expect(@account.positions.last.price).to eq(579.25)
        expect(@account.positions.last.price_traded).to eq('579-1/4')
        expect(@account.positions.last.mark).to eq(579.00)
        expect(@account.positions.last.bot).to eq(0)
        expect(@account.positions.last.sld).to eq(5)
        expect(@account.positions.last.bot_off).to eq(0)
        expect(@account.positions.last.sld_off).to eq(0)
        expect(@account.positions.last.net).to eq(-5)
        expect(@account.positions.last.currency.code).to eq('USD')
      end

      it "and one statement position is found" do
        expect(@account.statement_positions.count).to eq(1)
      end

      it "and the statement position has appropriate attributes" do
        expect(@account.statement_positions.last.stated_on).to eq(Date.parse('2020-12-23'))
        expect(@account.statement_positions.last.posted_on).to eq(Date.parse('2020-12-23'))
        expect(@account.statement_positions.last.traded_on).to eq(Date.parse('2020-12-23'))
        expect(@account.statement_positions.last.price).to eq(579.25)
        expect(@account.statement_positions.last.mark).to eq(579.00)
        expect(@account.statement_positions.last.bot).to eq(0)
        expect(@account.statement_positions.last.sld).to eq(5)
        expect(@account.statement_positions.last.net).to eq(-5)
        expect(@account.statement_positions.last.currency_code).to eq('USD')
      end

      # only BOT so no netting...

      it "and no net position is found" do
        expect(@account.position_nettings.count).to eq(0)
      end

      it "and appropriate charge are charged" do
        expect(Charge.count).to eq(1)
      end

      it "and an appropriate charge journal entry appears" do
        expect(JournalEntry.charges.count).to eq(1)
      end

      it "and an appropriate charge ledger entry appears" do
        expect(LedgerEntry.charges.count).to eq(1)
      end

      it "and 2 money lines" do
        expect(@account.money_lines.count).to eq(2)
      end

      it "and appropriate USD SEGN money line values exist" do
        currency = Currency.usd
        segregation = Segregation.find_by_code('SEGN')

        money_line = @account.money_lines.currency(currency.id).segregation(segregation.id).first

        expect(money_line.posted_on).to eq(Date.parse('2020-12-23'))
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-1.00)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(-98.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-99.00, 8))
        expect(money_line.open_trade_equity).to eq(62.50)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-36.50, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-36.50, 8))
      end

      it "and appropriate USD BASE money line values exist" do
        currency = Currency.usd
        segregation = Segregation.find_by_code('SEGB')

        money_line = @account.money_lines.currency(currency.id).segregation(segregation.id).first

        expect(money_line.posted_on).to eq(Date.parse('2020-12-23'))
        expect(money_line.kind).to eq('BASE')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-1.00)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(-98.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-99.00, 8))
        expect(money_line.open_trade_equity).to eq(62.50)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-36.50, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-36.50, 8))
      end

      it "and statement position lines exist" do
        expect(@account.statement_positions.stated_on(Date.parse('2020-12-23')).count).to eq(1)
      end

    end
  end

end
