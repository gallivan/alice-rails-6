RSpec.describe Account, type: :model do

  #
  # One fill and one day with no netting.
  #

  describe "#handle_fill CME:48Z16:03000:21937832663 - one day one fill" do

    before(:all) do
      puts "preping begun."

      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start

      Rails.cache.clear

      acct_code = '03000'

      firm = FactoryBot.create(:entity_emm)

      FactoryBot.create(:account_regular, entity: firm, code: acct_code, name: firm.name + " account #{acct_code}")

      find_or_create(:entity_cme)

      FactoryBot.create(:system_cme)
      FactoryBot.create(:entity_alias_cme_cme)
      FactoryBot.create(:dealing_venue_cme)
      FactoryBot.create(:dealing_venue_alias_cmesys_cme)

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

      puts "preping ended."

      # <?xml version="1.0" encoding="UTF-8"?>
      # <FIXML>
      #   <TrdCaptRpt RptID="21962308953" TrdTyp="0" ExecID="15675020160725094044TN0004503" TrdDt="2016-07-25"
      #               BizDt="2016-07-25"
      #               MLegRptTyp="1" MtchStat="0" MsgEvtSrc="REG" TrdID="102411" LastQty="1" LastPx="111.975"
      #               TxnTm="2016-07-25T09:40:44-05:00" SettlCcy="USD" SettlDt="2016-12-30"
      #               OrigTrdID="1561EEC09D4LTP0302D1BC930"
      #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
      #     <Instrmt ID="48" Desc="LIVE CATTLE FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="201612" MatDt="2016-12-30" Mult="400"
      #              Exch="CME" UOM="lbs" UOMQty="40000" PxUOM="LBS" PxUOMQty="100" ValMeth="FUT" Fctr="1"
      #              PxQteCcy="USD"></Instrmt>
      #     <Amt Typ="TVAR" Amt="90" Ccy="USD"/>
      #     <RptSide Side="1" ClOrdID="EK4H" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0" AgrsrInd="N">
      #       <Pty ID="CME" R="21"></Pty>
      #       <Pty ID="353" R="4"></Pty>
      #       <Pty ID="CME" R="22"></Pty>
      #       <Pty ID="353" R="1"></Pty>
      #       <Pty ID="03000" R="24">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="3E3L" R="12"></Pty>
      #       <Pty ID="353" R="38">
      #         <Sub ID="2" Typ="26"/>
      #       </Pty>
      #       <Pty ID="353" R="7"></Pty>
      #       <RegTrdID ID="FECF1561EEC09D4LTP0302D1BC932" Src="1010000023" Typ="0" Evnt="2"/>
      #     </RptSide>
      #   </TrdCaptRpt>
      # </FIXML>
      #
      # get execution report
      name = "#{Rails.root}/etc/data/cme/rspec/CME:48Z16:03000:2016-07-25:21962308953.xml"
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
          mark: 111.925,
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

    context "when account 03000 executes CME:48Z16 via CME EOD with id 21959018827" do

      it "then account with code '03000' should exist" do
        expect(@account.code).to eql('03000')
      end

      it "and one fill is found" do
        expect(@account.deal_leg_fills.count).to eq(1)
      end

      it "and the fill has appropriate attributes" do
        expect(@account.deal_leg_fills.last.system.code).to eq('CMEsys')
        expect(@account.deal_leg_fills.last.dealing_venue.code).to eq('CME')
        expect(@account.deal_leg_fills.last.dealing_venue_done_id).to eq('15675020160725094044TN0004503 102411')
        expect(@account.deal_leg_fills.last.claim.code).to eq('CME:48Z16')
        expect(@account.deal_leg_fills.last.done).to eq(+1)
        expect(@account.deal_leg_fills.last.price).to eq(111.975)
        expect(@account.deal_leg_fills.last.price_traded).to eq('111.975')
        expect(@account.deal_leg_fills.last.posted_on).to eq(Date.parse('2016-07-25'))
        expect(@account.deal_leg_fills.last.traded_on).to eq(Date.parse('2016-07-25'))
        expect(@account.deal_leg_fills.last.kind).to eq('DATA')
      end

      it "and one position is found" do
        expect(@account.positions.count).to eq(1)
      end

      it "and the position has appropriate attributes" do
        expect(@account.positions.last.posted_on).to eq(Date.parse('2016-07-25'))
        expect(@account.positions.last.traded_on).to eq(Date.parse('2016-07-25'))
        expect(@account.positions.last.price).to eq(111.975)
        expect(@account.positions.last.price_traded).to eq('111.975')
        expect(@account.positions.last.mark).to eq(111.925)
        expect(@account.positions.last.bot).to eq(+1)
        expect(@account.positions.last.sld).to eq(0)
        expect(@account.positions.last.bot_off).to eq(0)
        expect(@account.positions.last.sld_off).to eq(0)
        expect(@account.positions.last.net).to eq(+1)
        expect(@account.positions.last.currency.code).to eq('USD')
      end

      it "and one statement position is found" do
        expect(@account.statement_positions.count).to eq(1)
      end

      it "and the statement position has appropriate attributes" do
        expect(@account.statement_positions.last.stated_on).to eq(Date.parse('2016-07-25'))
        expect(@account.statement_positions.last.posted_on).to eq(Date.parse('2016-07-25'))
        expect(@account.statement_positions.last.traded_on).to eq(Date.parse('2016-07-25'))
        expect(@account.statement_positions.last.price).to eq(111.975)
        expect(@account.statement_positions.last.mark).to eq(111.925)
        expect(@account.statement_positions.last.bot).to eq(1)
        expect(@account.statement_positions.last.sld).to eq(0)
        expect(@account.statement_positions.last.net).to eq(+1)
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

        expect(money_line.posted_on).to eq(Date.parse('2016-07-25'))
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.20)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(-98.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-98.20, 8))
        expect(money_line.open_trade_equity).to eq(-20.00)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-118.20, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-118.20, 8))
      end

      it "and appropriate USD BASE money line values exist" do
        currency = Currency.usd
        segregation = Segregation.find_by_code('SEGB')

        money_line = @account.money_lines.currency(currency.id).segregation(segregation.id).first

        expect(money_line.posted_on).to eq(Date.parse('2016-07-25'))
        expect(money_line.kind).to eq('BASE')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.charges).to eq(-0.20)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(-98.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.ledger_balance).to eq(BigDecimal(-98.20, 8))
        expect(money_line.open_trade_equity).to eq(-20.00)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-118.20, 8))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-118.20, 8))
      end

      it "and statement position lines exist" do
        expect(@account.statement_positions.stated_on(Date.parse('2016-07-25')).count).to eq(1)
      end

    end
  end

end
