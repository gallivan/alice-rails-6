RSpec.describe Account do

  #
  # One fill and one day with no netting.
  #

  describe "#handle_fill EUREX:FGBLM21.:00902 - one day one fill" do

    before(:all) do
      puts "preparation begun."

      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start

      Rails.cache.clear

      acct_code = '00902'

      firm = FactoryBot.create(:entity_emm)

      account = FactoryBot.create(:account_regular, entity: firm, code: acct_code, name: firm.name + " account #{acct_code}")

      find_or_create(:entity_eurex)

      system = FactoryBot.create(:system_ghf)
      FactoryBot.create(:account_alias, system: system, account: account, code: 'LEMMS10')

      # FactoryBot.create(:account_alias_eod_ghf_00902)

      FactoryBot.create(:dealing_venue_eurex)
      FactoryBot.create(:dealing_venue_alias_eod_ghf_eurex)
      FactoryBot.create(:claim_type_future)
      FactoryBot.create(:position_status_opn)
      FactoryBot.create(:adjustment_type_fee)

      FactoryBot.create(:currency_usd)
      FactoryBot.create(:currency_eur)

      FactoryBot.create(:segregation_segn)
      FactoryBot.create(:segregation_base)

      FactoryBot.create(:chargeable_type_srv)
      FactoryBot.create(:chargeable_type_exg)
      FactoryBot.create(:chargeable_type_brk)

      FactoryBot.create(:journal_sole)
      FactoryBot.create(:journal_entry_type_adj)
      FactoryBot.create(:journal_entry_type_ote)
      FactoryBot.create(:journal_entry_type_fee)
      FactoryBot.create(:journal_entry_type_com)

      FactoryBot.create(:ledger_sole)
      FactoryBot.create(:ledger_entry_type_adj)
      FactoryBot.create(:ledger_entry_type_chg)
      FactoryBot.create(:ledger_entry_type_leg)
      FactoryBot.create(:ledger_entry_type_ote)
      FactoryBot.create(:ledger_entry_type_liq)
      FactoryBot.create(:ledger_entry_type_cshact)

      puts "preparation ended."

      # get execution report
      name = "#{Rails.root}/etc/data/ghf/EUREX:FGBL:202106:00902.csv"
      csv = File.open(name).readline
      hash = {}
      hash[:csv] = csv
      hash[:root] = 'EOD_GHF'

      puts '*' * 50
      puts csv
      puts '*' * 50

      # normalize hash
      norm = Workers::Normalizer.normalize_eod_ghf_csv(hash)

      puts '*' * 50
      puts norm
      puts '*' * 50

      # book fill
      @account = Account.find(norm[:account_id])
      @account.handle_fill(norm)

      # create adjustment
      adjustment_type = AdjustmentType.find_by_code('FEE')
      segregation = Segregation.find_by_code('SEGN')
      params = {
        posted_on: @account.deal_leg_fills.last.posted_on.to_s,
        account_id: @account.id,
        currency_id: Currency.eur.id,
        segregation_id: segregation.id,
        adjustment_type_id: adjustment_type.id,
        amount: -98,
        memo: 'testing'
      }
      Builders::AdjustmentBuilder.build(params)

      claim = @account.deal_leg_fills.last.claim

      # create EXG Chargeable

      params = {
        chargeable_type_id: ChargeableType.find_by_code('EXG').id,
        claim_set_id: claim.claim_set.id,
        currency_id: Currency.eur.id,
        amount: 0.20,
        begun_on: 1.year.ago,
        ended_on: 1.year.from_now
      }
      Chargeable.create!(params)

      # create BRK Chargeable

      params = {
        chargeable_type_id: ChargeableType.find_by_code('BRK').id,
        claim_set_id: claim.claim_set.id,
        currency_id: Currency.usd.id,
        amount: 0.05,
        begun_on: 10.year.ago,
        ended_on: 10.year.from_now
      }
      Chargeable.create!(params)

      # create SRV Chargeable

      params = {
        chargeable_type_id: ChargeableType.find_by_code('SRV').id,
        claim_set_id: claim.claim_set.id,
        currency_id: Currency.usd.id,
        amount: 0.035,
        begun_on: 1.year.ago,
        ended_on: 1.year.from_now
      }
      Chargeable.create!(params)

      # post claim mark

      params = {
        system_id: @account.deal_leg_fills.last.system.id,
        posted_on: @account.deal_leg_fills.last.posted_on,
        mark: 133.670,
        approved: false
      }
      claim.post_claim_mark(params)

      # post EUR mark

      params = {
        currency_id: Currency.eur.id,
        posted_on: @account.deal_leg_fills.last.posted_on,
        mark: 1.100
      }
      CurrencyMark.post_mark(params)

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

    context "when account 00902 executes EUREX:FGBLM21 via GHF" do

      it "then account with code '00902' should exist" do
        expect(@account.code).to eql('00902')
      end

      it "and one fill is found" do
        expect(@account.deal_leg_fills.count).to eq(1)
      end

      it "and the fill has appropriate attributes" do
        expect(@account.deal_leg_fills.last.system.code).to eq('GHF')
        expect(@account.deal_leg_fills.last.dealing_venue.code).to eq('EUREX')
        expect(@account.deal_leg_fills.last.dealing_venue_done_id).to eq('549300457HG10ZKG2W41xLONx1081158720')
        expect(@account.deal_leg_fills.last.claim.code).to eq('EUREX:FGBLM21')
        expect(@account.deal_leg_fills.last.claim.name).to eq('FGBL JUN-21')
        expect(@account.deal_leg_fills.last.done).to eq(1.0)
        expect(@account.deal_leg_fills.last.price).to eq(0 + BigDecimal(169.90,12))
        expect(@account.deal_leg_fills.last.price_traded).to eq('169.9000000')
        expect(@account.deal_leg_fills.last.posted_on).to eq(Date.parse('2021-06-04'))
        expect(@account.deal_leg_fills.last.traded_on).to eq(Date.parse('2021-06-04'))
        expect(@account.deal_leg_fills.last.traded_at.strftime('%H:%m:%S')).to eq('00:06:00')
        expect(@account.deal_leg_fills.last.kind).to eq('DATA')
      end

      it "and one position is found" do
        expect(@account.positions.count).to eq(1)
      end

      it "and the position has appropriate attributes" do
        expect(@account.positions.last.posted_on).to eq(Date.parse('2021-06-04'))
        expect(@account.positions.last.traded_on).to eq(Date.parse('2021-06-04'))
        expect(@account.positions.last.price).to eq(BigDecimal(169.90, 12))
        expect(@account.positions.last.price_traded).to eq('169.9000000')
        expect(@account.positions.last.mark).to eq(133.670)
        expect(@account.positions.last.bot).to eq(1)
        expect(@account.positions.last.sld).to eq(0)
        expect(@account.positions.last.bot_off).to eq(0)
        expect(@account.positions.last.sld_off).to eq(0)
        expect(@account.positions.last.net).to eq(1)
        expect(@account.positions.last.currency.code).to eq('EUR')
      end

      it "and one statement position is found" do
        expect(@account.statement_positions.count).to eq(1)
      end

      it "and the statement position has appropriate attributes" do
        expect(@account.statement_positions.last.stated_on).to eq(Date.parse('2021-06-04'))
        expect(@account.statement_positions.last.posted_on).to eq(Date.parse('2021-06-04'))
        expect(@account.statement_positions.last.traded_on).to eq(Date.parse('2021-06-04'))
        expect(@account.statement_positions.last.price).to eq(BigDecimal(169.90, 12))
        expect(@account.statement_positions.last.mark).to eq(133.670)
        expect(@account.statement_positions.last.bot).to eq(1)
        expect(@account.statement_positions.last.sld).to eq(0)
        expect(@account.statement_positions.last.net).to eq(1)
        expect(@account.statement_positions.last.currency_code).to eq('EUR')
      end

      it "and no net position is found" do
        expect(@account.position_nettings.count).to eq(0)
      end

      it "and appropriate charges are made" do
        expect(Chargeable.count).to eq(3)

        charge = Chargeable.order(:id).first
        expect(charge.amount).to eq(0.20)
        expect(charge.currency.code).to eq('EUR')
        expect(charge.chargeable_type.code).to eq('EXG')

        charge = Chargeable.order(:id).second
        expect(charge.amount).to eq(0.05)
        expect(charge.currency.code).to eq('USD')
        expect(charge.chargeable_type.code).to eq('BRK')

        charge = Chargeable.order(:id).third
        expect(charge.amount).to eq(0.035)
        expect(charge.currency.code).to eq('USD')
        expect(charge.chargeable_type.code).to eq('SRV')
      end

      it "and an appropriate fee journal entry appears" do
        expect(JournalEntry.charges.count).to eq(3)

        entry = JournalEntry.charges.first
        expect(entry.amount).to eq(-0.20)
        expect(entry.currency.code).to eq('EUR')
        expect(entry.segregation.code).to eq('SEGN')
        expect(entry.journal_entry_type.code).to eq('FEE')

        entry = JournalEntry.charges.second
        expect(entry.amount).to eq(-0.05)
        expect(entry.currency.code).to eq('USD')
        expect(entry.segregation.code).to eq('SEGN')
        expect(entry.journal_entry_type.code).to eq('COM')

        entry = JournalEntry.charges.third
        expect(entry.amount).to eq(-0.035)
        expect(entry.currency.code).to eq('USD')
        expect(entry.segregation.code).to eq('SEGN')
        expect(entry.journal_entry_type.code).to eq('FEE')
      end

      it "and an appropriate charge ledger entry appears" do
        expect(LedgerEntry.charges.count).to eq(2)

        entry = LedgerEntry.charges.order(:currency_id).first
        expect(entry.amount).to eq(BigDecimal(-0.085, 12))
        expect(entry.currency.code).to eq('USD')
        expect(entry.segregation.code).to eq('SEGN')
        expect(entry.ledger_entry_type.code).to eq('CHG')

        entry = LedgerEntry.charges.order(:currency_id).last
        expect(entry.amount).to eq(-0.20)
        expect(entry.currency.code).to eq('EUR')
        expect(entry.segregation.code).to eq('SEGN')
        expect(entry.ledger_entry_type.code).to eq('CHG')
      end

      it "and an appropriate number of money lines appear" do
        expect(@account.money_lines.count).to eq(3)
      end

      it "and appropriate EUR SEG7 money line values exist" do
        currency = Currency.eur
        segregation = Segregation.find_by_code('SEGN')

        money_line = @account.money_lines.currency(currency.id).segregation(segregation.id).first

        expect(money_line.posted_on).to eq(Date.parse('2021-06-04'))
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('EUR')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(-98.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.charges).to eq(-0.20)
        expect(money_line.ledger_balance).to eq(-98.20)
        expect(money_line.open_trade_equity).to eq(-36_230.00)
        expect(money_line.cash_account_balance).to eq(-36_328.20)
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(-36_328.20)
      end

      it "and appropriate USD SEGN money line values exist" do
        currency = Currency.usd
        segregation = Segregation.find_by_code('SEGN')

        money_line = @account.money_lines.currency(currency.id).segregation(segregation.id).first

        expect(money_line.posted_on).to eq(Date.parse('2021-06-04'))
        expect(money_line.kind).to eq('HELD')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.cash).to eq(0.00)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(0.00)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.charges).to eq(BigDecimal(-0.085, 12))
        expect(money_line.ledger_balance).to eq(BigDecimal(-0.085, 12))
        expect(money_line.open_trade_equity).to eq(0.00)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-0.085, 12))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-0.085, 12))
      end

      it "and appropriate USD BASE money line values exist" do
        currency = Currency.usd
        segregation = Segregation.find_by_code('SEGB')

        money_line = @account.money_lines.currency(currency.id).segregation(segregation.id).first

        expect(money_line.posted_on).to eq(Date.parse('2021-06-04'))
        expect(money_line.kind).to eq('BASE')
        expect(money_line.currency.code).to eq('USD')
        expect(money_line.beginning_balance).to eq(0.00)
        expect(money_line.pnl_futures).to eq(0.00)
        expect(money_line.adjustments).to eq(-107.80)
        expect(money_line.rebates).to eq(0.00)
        expect(money_line.charges).to eq(-0.305)
        expect(money_line.ledger_balance).to eq(BigDecimal(-108.105, 12))
        expect(money_line.open_trade_equity).to eq(-39_853.00)
        expect(money_line.cash_account_balance).to eq(BigDecimal(-39_961.105, 12))
        expect(money_line.margin).to eq(0.00)
        expect(money_line.long_option_value).to eq(0.00)
        expect(money_line.short_option_value).to eq(0.00)
        expect(money_line.net_option_value).to eq(0.00)
        expect(money_line.net_liquidating_balance).to eq(BigDecimal(-39_961.105, 12))
      end

      it "and statement position lines exist" do
        expect(@account.statement_positions.stated_on(Date.parse('2021-06-04')).count).to eq(1)
      end

    end

  end

end
