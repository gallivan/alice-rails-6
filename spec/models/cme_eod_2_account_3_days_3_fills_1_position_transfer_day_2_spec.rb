RSpec.describe Account, type: :model do

  before :all do
    puts "preparing begun."

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start

    Rails.cache.clear

    acct_code = '00123'

    user = FactoryBot.create(:user)
    puts user.inspect
    
    firm = FactoryBot.create(:entity_emm)

    FactoryBot.create(:account_regular, entity: firm, code: acct_code, name: "#{firm.name} account #{acct_code}")

    FactoryBot.create(:entity_cbt)

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

    @fm_account = Account.find_by_code('00123')
    @to_account = build(:account) # FactoryBot
    @to_account.save!

    ##############
    # 2016-07-21 #
    ##############

    @day_1 = Date.parse('2016-07-21')
    packer = Workers::PackerOfEodCme.new

    # sld

    # <?xml version="1.0" encoding="UTF-8"?>
    # <FIXML>
    #   <TrdCaptRpt RptID="21943431598" TrdTyp="0" TrdSubTyp="7" ExecID="99548920160721101450TN0018756" TrdDt="2016-07-21"
    #               BizDt="2016-07-21" MLegRptTyp="2" MtchStat="0" MsgEvtSrc="REG" TrdID="135740" LastQty="2" LastPx="3.375"
    #               TxnTm="2016-07-21T10:14:50-05:00" SettlCcy="USD" SettlDt="2016-09-14"
    #               OrigTrdID="155FADF8544LTP0201DAECF44"
    #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
    #     <Instrmt ID="C" Desc="CORN FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="201609" MatDt="2016-09-14" Mult="5000" Exch="CBT"
    #              UOM="Bu" UOMQty="5000" PxUOM="BU" PxUOMQty="1" ValMeth="FUT" Fctr="1" PxQteCcy="USD"></Instrmt>
    #     <Amt Typ="TVAR" Amt="325" Ccy="USD"/>
    #     <RptSide Side="2" ClOrdID="19UA" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0" AgrsrInd="N">
    #       <Pty ID="CME" R="21"></Pty>
    #       <Pty ID="353" R="4"></Pty>
    #       <Pty ID="CBT" R="22"></Pty>
    #       <Pty ID="330" R="1"></Pty>
    #       <Pty ID="00123" R="24">
    #         <Sub ID="2" Typ="26"/>
    #       </Pty>
    #       <Pty ID="3E3L" R="12"></Pty>
    #       <Pty ID="330B" R="38">
    #         <Sub ID="2" Typ="26"/>
    #       </Pty>
    #       <Pty ID="330" R="7"></Pty>
    #       <RegTrdID ID="FECF155FADF8544LTP0201DAECF4A" Src="1010000023" Typ="0" Evnt="2"/>
    #     </RptSide>
    #   </TrdCaptRpt>
    # </FIXML>

    # pick
    name = "#{Rails.root}/etc/data/cme/rspec/CBT:CU16:00123:2016-07-21:21943431598.xml"
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

    # bot

    # <?xml version="1.0" encoding="UTF-8"?>
    # <FIXML>
    #   <TrdCaptRpt RptID="21946403113" TrdTyp="0" TrdSubTyp="7" ExecID="14541120160721131457TN0062948" TrdDt="2016-07-21"
    #               BizDt="2016-07-21" MLegRptTyp="2" MtchStat="0" MsgEvtSrc="REG" TrdID="158112" LastQty="1" LastPx="3.375"
    #               TxnTm="2016-07-21T13:14:57-05:00" SettlCcy="USD" SettlDt="2016-09-14"
    #               OrigTrdID="155FADF8544LTP0201DBFFBA0"
    #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
    #     <Instrmt ID="C" Desc="CORN FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="201609" MatDt="2016-09-14" Mult="5000" Exch="CBT"
    #              UOM="Bu" UOMQty="5000" PxUOM="BU" PxUOMQty="1" ValMeth="FUT" Fctr="1" PxQteCcy="USD"></Instrmt>
    #     <Amt Typ="TVAR" Amt="-162.5" Ccy="USD"/>
    #     <RptSide Side="1" ClOrdID="1DYM" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0" AgrsrInd="N">
    #       <Pty ID="CME" R="21"></Pty>
    #       <Pty ID="353" R="4"></Pty>
    #       <Pty ID="CBT" R="22"></Pty>
    #       <Pty ID="330" R="1"></Pty>
    #       <Pty ID="00123" R="24">
    #         <Sub ID="2" Typ="26"/>
    #       </Pty>
    #       <Pty ID="3E3L" R="12"></Pty>
    #       <Pty ID="330B" R="38">
    #         <Sub ID="2" Typ="26"/>
    #       </Pty>
    #       <Pty ID="330" R="7"></Pty>
    #       <RegTrdID ID="FECF155FADF8544LTP0201DBFFBA2" Src="1010000023" Typ="0" Evnt="2"/>
    #     </RptSide>
    #   </TrdCaptRpt>
    # </FIXML>

    # pick
    name = "#{Rails.root}/etc/data/cme/rspec/CBT:CU16:00123:2016-07-21:21946403113.xml"
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

    claim = @fm_account.deal_leg_fills.last.claim

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

    params = [
        {
            claim_id: claim.id,
            system_id: @fm_account.deal_leg_fills.last.system.id,
            posted_on: @day_1,
            mark: 337.00,
            approved: false
        }
    ]
    params.each { |p| ClaimMark.post_mark(p) }

    params = [
        {
            currency_id: Currency.usd.id,
            posted_on: @day_1,
            mark: 1.0
        }
    ]

    params.each { |p| CurrencyMark.post_mark(p) }

    @fm_account.eod_for(@day_1) # thursday
    @to_account.eod_for(@day_1) # thursday

    ##############
    # 2016-07-22 #
    ##############

    @day_2 = Date.parse('2016-07-22')

    params = [
        {
            system_id: @fm_account.deal_leg_fills.last.system.id,
            claim_id: claim.id,
            posted_on: @day_2,
            mark: 336.75,
            approved: false
        }
    ]
    params.each { |p| ClaimMark.post_mark(p) }

    params = [
        {
            currency_id: Currency.usd.id,
            posted_on: @day_2,
            mark: 1.0
        },
    ]
    params.each { |p| CurrencyMark.post_mark(p) }

    # do position transfer

    note = 'position transfer testing'
    position = @fm_account.positions.order(:id).last
    bot_to_transfer = 0
    sld_to_transfer = position.sld
    Builders::PositionTransferBuilder.build(user, position, @to_account, bot_to_transfer, sld_to_transfer, note)

    # do eod

    @fm_account.eod_for(@day_2) # friday
    @to_account.eod_for(@day_2) # friday

    ##############
    # 2016-07-25 #
    ##############

    @day_3 = Date.parse('2016-07-25')

    # bot

    # <?xml version="1.0" encoding="UTF-8"?>
    # <FIXML>
    #   <TrdCaptRpt RptID="21961486254" TrdTyp="0" TrdSubTyp="7" ExecID="10047720160725085701TN0012466" TrdDt="2016-07-25"
    #               BizDt="2016-07-25" MLegRptTyp="2" MtchStat="0" MsgEvtSrc="REG" TrdID="130532" LastQty="3" LastPx="3.35"
    #               TxnTm="2016-07-25T08:57:01-05:00" SettlCcy="USD" SettlDt="2016-09-14"
    #               OrigTrdID="1561EEC09C8LTP0202D12C222"
    #               PxSubTyp="1" VenueTyp="E" VenuTyp="E">
    #     <Instrmt ID="C" Desc="CORN FUTURES" CFI="FCAPSO" SecTyp="FUT" MMY="201609" MatDt="2016-09-14" Mult="5000" Exch="CBT"
    #              UOM="Bu" UOMQty="5000" PxUOM="BU" PxUOMQty="1" ValMeth="FUT" Fctr="1" PxQteCcy="USD"></Instrmt>
    #     <Amt Typ="TVAR" Amt="-37.5" Ccy="USD"/>
    #     <RptSide Side="1" ClOrdID="1MP5" CustCpcty="2" OrdTyp="L" SesID="EOD" SesSub="E" AllocInd="0" AgrsrInd="N">
    #       <Pty ID="CME" R="21"></Pty>
    #       <Pty ID="353" R="4"></Pty>
    #       <Pty ID="CBT" R="22"></Pty>
    #       <Pty ID="330" R="1"></Pty>
    #       <Pty ID="00123" R="24">
    #         <Sub ID="2" Typ="26"/>
    #       </Pty>
    #       <Pty ID="3E3L" R="12"></Pty>
    #       <Pty ID="330B" R="38">
    #         <Sub ID="2" Typ="26"/>
    #       </Pty>
    #       <Pty ID="330" R="7"></Pty>
    #       <RegTrdID ID="FECF1561EEC09C8LTP0202D12C224" Src="1010000023" Typ="0" Evnt="2"/>
    #     </RptSide>
    #   </TrdCaptRpt>
    # </FIXML>

    # pick
    name = "#{Rails.root}/etc/data/cme/rspec/CBT:CU16:00123:2016-07-25:21961486254.xml"
    fix = File.open(name).read
    # pack
    hash = Workers::Packer.new.cme_fixml_to_hash(fix)
    # book
    norm = Workers::Normalizer.normalize_cme_eod(hash)
    booker_report = Workers::Booker.new.build_report(norm)
    norm[:booker_report_id] = booker_report.id
    @fm_account = Account.find(norm[:account_id])
    @fm_account.handle_fill(norm)
    booker_report.update!(fate: 'DONE')

    params = [
        {
            system_id: @fm_account.deal_leg_fills.last.system.id,
            claim_id: claim.id,
            posted_on: @day_3,
            mark: 336.50,
            approved: false
        }
    ]
    params.each { |p| ClaimMark.post_mark(p) }

    params = [
        {
            currency_id: Currency.usd.id,
            posted_on: @day_3,
            mark: 1.0
        },
    ]
    params.each { |p| CurrencyMark.post_mark(p) }

    @fm_account.eod_for(@day_3) # monday
    @to_account.eod_for(@day_3) # monday

    puts "Ended before :all"
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  ################
  # day 3 status #
  ################

  context "assess day 3 state" do

    it "then account with code '00123' should exist" do
      expect(@fm_account.code).to eql('00123')
    end

    it "and 2 fills are found posted on day 1 for fm_account" do
      expect(@fm_account.deal_leg_fills.posted_on(@day_1).count).to eq(2)
    end

    it "and 0 fills are found posted on day 1 for to_account" do
      expect(@to_account.deal_leg_fills.posted_on(@day_1).count).to eq(0)
    end

    it "and 0 fills are found posted on day 2 for fm_account" do
      expect(@fm_account.deal_leg_fills.posted_on(@day_2).count).to eq(0)
    end

    it "and 0 fills are found posted on day 2 for to_account" do
      expect(@to_account.deal_leg_fills.posted_on(@day_2).count).to eq(0)
    end

    it "and 1 fill is found posted on day 3 for fm_account" do
      expect(@fm_account.deal_leg_fills.posted_on(@day_3).count).to eq(1)
    end

    it "and 0 fill is found posted on day 3 for to_account" do
      expect(@to_account.deal_leg_fills.posted_on(@day_3).count).to eq(0)
    end

    it "and the fm_account day 1 BOT fill has appropriate attributes" do
      fill = @fm_account.deal_leg_fills.bot.posted_on(@day_1).order(:id).first

      expect(fill.system.code).to eq('CMEsys')
      expect(fill.dealing_venue.code).to eq('CBT')
      expect(fill.dealing_venue_done_id).to eq('14541120160721131457TN0062948 158112')
      expect(fill.claim.code).to eq('CBT:CU16')
      expect(fill.done).to eq(+1)
      expect(fill.price).to eq(337.50)
      expect(fill.price_traded).to eq('337-1/2')
      expect(fill.posted_on).to eq(@day_1)
      expect(fill.traded_on).to eq(@day_1)
      expect(fill.kind).to eq('DATA')
    end

    it "and the fm_account day 1 SLD fill has appropriate attributes" do
      fill = @fm_account.deal_leg_fills.sld.posted_on(@day_1).order(:id).first

      expect(fill.system.code).to eq('CMEsys')
      expect(fill.dealing_venue.code).to eq('CBT')
      expect(fill.dealing_venue_done_id).to eq('99548920160721101450TN0018756 135740')
      expect(fill.claim.code).to eq('CBT:CU16')
      expect(fill.done).to eq(-2)
      expect(fill.price).to eq(337.50)
      expect(fill.price_traded).to eq('337-1/2')
      expect(fill.posted_on).to eq(@day_1)
      expect(fill.traded_on).to eq(@day_1)
      expect(fill.kind).to eq('DATA')
    end

    it "and 2 positions are posted_on on or before day 3 for fm_account" do
      expect(@fm_account.positions.posted_on_or_before(@day_3).count).to eq(2)
    end

    it "and 1 positions are posted_on on or before day 3 for to_account" do
      expect(@to_account.positions.posted_on_or_before(@day_3).count).to eq(1)
    end

    it "and 1 position is posted_on day 1 for fm_account" do
      expect(@fm_account.positions.posted_on(@day_1).count).to eq(1)
    end

    it "and 1 position is posted_on day 1 for to_account" do
      expect(@to_account.positions.posted_on(@day_1).count).to eq(1)
    end

    it "and 0 position is posted_on day 2 for fm_account" do
      expect(@fm_account.positions.posted_on(@day_2).count).to eq(0)
    end

    it "and 0 position is posted_on day 2 for to_account" do
      expect(@to_account.positions.posted_on(@day_2).count).to eq(0)
    end

    it "and 0 position is posted_on day 3 for fm_account" do
      expect(@fm_account.positions.posted_on(@day_3).count).to eq(1)
    end

    it "and 0 position is posted_on day 3 for to_account" do
      expect(@to_account.positions.posted_on(@day_3).count).to eq(0)
    end

    it "and the fm_account day 1 position has appropriate attributes" do
      position = @fm_account.positions.posted_on(@day_1).first

      # +1 and -2 will net to -1 on day 1
      # -1 transfered on day 2

      expect(position.posted_on).to eq(@day_1)
      expect(position.traded_on).to eq(@day_1)
      expect(position.price).to eq(337.50)
      expect(position.price_traded).to eq('337-1/2')
      expect(position.mark).to eq(337)
      expect(position.bot).to eq(0)
      expect(position.sld).to eq(0)
      expect(position.bot_off).to eq(1)
      expect(position.sld_off).to eq(1)
      expect(position.net).to eq(0)
      expect(position.currency.code).to eq('USD')
    end

    it "and the fm_account day 2 position count is 0" do
      count = @fm_account.positions.posted_on(@day_2).count
      expect(count).to eq(0)
    end

    it "and the fm_account day 3 position has appropriate attributes" do
      position = @fm_account.positions.posted_on(@day_3).first

      expect(position.posted_on).to eq(@day_3)
      expect(position.traded_on).to eq(@day_3)
      expect(position.price).to eq(335.00)
      expect(position.price_traded).to eq('335')
      expect(position.mark).to eq(336.50)
      expect(position.bot).to eq(+3)
      expect(position.sld).to eq(0)
      expect(position.bot_off).to eq(0)
      expect(position.sld_off).to eq(0)
      expect(position.net).to eq(+3)
      expect(position.currency.code).to eq('USD')
    end

    it "and 1 netting positions are found for the fm_account" do
      expect(@fm_account.position_nettings.count).to eq(1)
    end

    it "and 1 position netting is posted_on day 1 for the fm_account" do
      expect(@fm_account.position_nettings.posted_on(@day_1).count).to eq(1)
    end

    it "and 0 position netting is posted_on day 2 for the fm_account" do
      expect(@fm_account.position_nettings.posted_on(@day_2).count).to eq(0)
    end

    it "and 0 position netting is posted_on day 3 for the fm_account" do
      expect(@fm_account.position_nettings.posted_on(@day_3).count).to eq(0)
    end

    it "and the fm_account day 1 position netting has appropriate attributes" do
      netting = @fm_account.position_nettings.posted_on(@day_1).first

      expect(netting.posted_on).to eq(@day_1)
      expect(netting.bot_price).to eq(337.500)
      expect(netting.sld_price).to eq(337.500)
      expect(netting.bot_price_traded).to eq('337-1/2')
      expect(netting.sld_price_traded).to eq('337-1/2')
      expect(netting.done).to eq(1)
      expect(netting.pnl).to eq(0)
      expect(netting.currency.code).to eq('USD')
    end

    it "and 3 statement positions are posted_on on or before day 3 for the fm_account" do
      expect(@fm_account.positions.posted_on_or_before(@day_3).count).to eq(2)
    end

    it "and 1 day 1 statement position is found for the fm_account" do
      expect(@fm_account.statement_positions.stated_on(@day_1).count).to eq(1)
    end

    it "and 0 day 2 statement position is found for the fm_account" do
      expect(@fm_account.statement_positions.stated_on(@day_2).count).to eq(0)
    end

    it "and 1 day 3 statement position is found for the fm_account" do
      expect(@fm_account.statement_positions.stated_on(@day_3).count).to eq(1)
    end

    it "and 0 day 1 statement position is found for the to_account" do
      expect(@to_account.statement_positions.stated_on(@day_1).count).to eq(0)
    end

    it "and 1 day 2 statement position is found for the to_account" do
      expect(@to_account.statement_positions.stated_on(@day_2).count).to eq(1)
    end

    it "and 1 day 3 statement position is found for the to_account" do
      expect(@to_account.statement_positions.stated_on(@day_3).count).to eq(1)
    end

    it "and 1 day 3 the statement position has appropriate attributes for the fm_account" do
      statement_position = @fm_account.statement_positions.stated_on(@day_3).first

      expect(statement_position.stated_on).to eq(@day_3)
      expect(statement_position.posted_on).to eq(@day_3)
      expect(statement_position.traded_on).to eq(@day_3)
      expect(statement_position.price).to eq(335.00)
      expect(statement_position.mark).to eq(336.50)
      expect(statement_position.bot).to eq(+3)
      expect(statement_position.sld).to eq(0)
      expect(statement_position.net).to eq(+3)
      expect(statement_position.currency_code).to eq('USD')
    end

    it "and 1 day 3 the statement position has appropriate attributes for the to_account" do
      statement_position = @to_account.statement_positions.stated_on(@day_3).first

      expect(statement_position.stated_on).to eq(@day_3)
      expect(statement_position.posted_on).to eq(@day_1)
      expect(statement_position.traded_on).to eq(@day_1)
      expect(statement_position.price).to eq(337.5)
      expect(statement_position.mark).to eq(336.50)
      expect(statement_position.bot).to eq(0)
      expect(statement_position.sld).to eq(1)
      expect(statement_position.net).to eq(-1)
      expect(statement_position.currency_code).to eq('USD')
    end

    it "and appropriate charges are charged" do
      expect(Charge.count).to eq(2)
      charge = Charge.last
      expect(charge.amount).to eq(-0.60)
      expect(charge.currency.code).to eq('USD')
    end

    it "and 2 money lines - for day 3 for the fm_account" do
      expect(@fm_account.money_lines.posted_on(@day_3).count).to eq(2)
    end

    it "and day 3 money lines appropriate for USD SEGN for the fm_account" do
      cid = Currency.usd.id
      sid = Segregation.find_by_code('SEGN').id

      money_line = @fm_account.money_lines.currency(cid).segregation(sid).posted_on(@day_3).first

      expect(money_line.posted_on).to eq(@day_3)
      expect(money_line.kind).to eq('HELD')
      expect(money_line.currency.code).to eq('USD')
      expect(money_line.beginning_balance).to eq(-0.60)
      expect(money_line.cash).to eq(0.00)
      expect(money_line.charges).to eq(-0.60)
      expect(money_line.pnl_futures).to eq(0.00)
      expect(money_line.adjustments).to eq(0.00)
      expect(money_line.rebates).to eq(0.00)
      expect(money_line.ledger_balance).to eq(-1.20)
      expect(money_line.open_trade_equity).to eq(225.00)
      expect(money_line.cash_account_balance).to eq(223.80)
      expect(money_line.margin).to eq(0.00)
      expect(money_line.long_option_value).to eq(0.00)
      expect(money_line.short_option_value).to eq(0.00)
      expect(money_line.net_option_value).to eq(0.00)
      expect(money_line.net_liquidating_balance).to eq(223.80)
    end

    it "and day 3 money lines appropriate for USD SEG BASE for the fm_account" do
      cid = Currency.usd.id
      sid = Segregation.find_by_code('SEGB').id

      money_line = @fm_account.money_lines.currency(cid).segregation(sid).posted_on(@day_3).first

      expect(money_line.posted_on).to eq(@day_3)
      expect(money_line.kind).to eq('BASE')
      expect(money_line.currency.code).to eq('USD')
      expect(money_line.beginning_balance).to eq(-0.60)
      expect(money_line.cash).to eq(0.00)
      expect(money_line.charges).to eq(-0.60)
      expect(money_line.pnl_futures).to eq(0.00)
      expect(money_line.adjustments).to eq(0.00)
      expect(money_line.rebates).to eq(0.00)
      expect(money_line.ledger_balance).to eq(-1.20)
      expect(money_line.open_trade_equity).to eq(225.00)
      expect(money_line.cash_account_balance).to eq(223.80)
      expect(money_line.margin).to eq(0.00)
      expect(money_line.long_option_value).to eq(0.00)
      expect(money_line.short_option_value).to eq(0.00)
      expect(money_line.net_option_value).to eq(0.00)
      expect(money_line.net_liquidating_balance).to eq(223.80)
    end

  end

  it "and day 3 money lines appropriate for USD SEGN for to_account" do
    cid = Currency.usd.id
    sid = Segregation.find_by_code('SEGN').id

    money_line = @to_account.money_lines.currency(cid).segregation(sid).posted_on(@day_3).first

    expect(money_line.posted_on).to eq(@day_3)
    expect(money_line.kind).to eq('HELD')
    expect(money_line.currency.code).to eq('USD')
    expect(money_line.beginning_balance).to eq(0.00)
    expect(money_line.cash).to eq(0.00)
    expect(money_line.charges).to eq(0.00)
    expect(money_line.pnl_futures).to eq(0.00)
    expect(money_line.adjustments).to eq(0.00)
    expect(money_line.rebates).to eq(0.00)
    expect(money_line.ledger_balance).to eq(0.00)
    expect(money_line.open_trade_equity).to eq(50.00)
    expect(money_line.cash_account_balance).to eq(50.00)
    expect(money_line.margin).to eq(0.00)
    expect(money_line.long_option_value).to eq(0.00)
    expect(money_line.short_option_value).to eq(0.00)
    expect(money_line.net_option_value).to eq(0.00)
    expect(money_line.net_liquidating_balance).to eq(50.00)
  end

  it "and day 3 money lines appropriate for USD SEG BASE for the to_account" do
    cid = Currency.usd.id
    sid = Segregation.find_by_code('SEGB').id

    money_line = @to_account.money_lines.currency(cid).segregation(sid).posted_on(@day_3).first

    expect(money_line.posted_on).to eq(@day_3)
    expect(money_line.kind).to eq('BASE')
    expect(money_line.currency.code).to eq('USD')
    expect(money_line.beginning_balance).to eq(0.00)
    expect(money_line.cash).to eq(0.00)
    expect(money_line.charges).to eq(0.00)
    expect(money_line.pnl_futures).to eq(0.00)
    expect(money_line.adjustments).to eq(0.00)
    expect(money_line.rebates).to eq(0.00)
    expect(money_line.ledger_balance).to eq(0.00)
    expect(money_line.open_trade_equity).to eq(50.00)
    expect(money_line.cash_account_balance).to eq(50.00)
    expect(money_line.margin).to eq(0.00)
    expect(money_line.long_option_value).to eq(0.00)
    expect(money_line.short_option_value).to eq(0.00)
    expect(money_line.net_option_value).to eq(0.00)
    expect(money_line.net_liquidating_balance).to eq(50.00)
  end

end
