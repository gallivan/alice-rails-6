# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  entity_id       :integer          not null
#  account_type_id :integer          not null
#  code            :string           not null
#  name            :string           not null
#  active          :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  group_id        :integer
#

class Account < ApplicationRecord
  validates :entity, presence: true
  validates :account_type, presence: true
  validates :code, presence: true
  validates :name, presence: true
  # validates :active, presence: true # commented out because ActiveAdmin uses 1 and 0 - which generates nil on save

  belongs_to :entity
  belongs_to :account_type

  has_many :account_aliases

  has_many :managed_accounts
  has_many :users, through: :managed_accounts

  has_many :charges
  has_many :adjustments

  has_many :journal_entries
  has_many :ledger_entries

  has_many :deal_leg_fills
  has_many :positions
  has_many :position_nettings
  has_many :money_lines

  has_many :statement_charges
  has_many :statement_positions
  has_many :statement_adjustments
  has_many :statement_money_lines
  has_many :statement_deal_leg_fills
  has_many :statement_position_nettings

  has_many :group_members, class_name: "Account", foreign_key: "group_id"

  has_many :account_portfolios
  has_many :portfolios, through: :account_portfolios

  scope :active, -> { where(active: true) }
  scope :grp, -> { joins(:account_type).where("account_types.code = 'GRP'") }
  scope :reg, -> { joins(:account_type).where("account_types.code = 'REG'") }
  scope :enm, -> { joins(:account_type).where("account_types.code = 'ENM'") }

  BASE_FILE_NAMES = %W(daily_account_statement_summary daily_account_statement)

  def self.select_options
    active.select("id, code").order(:code).all.collect { |a| [a.code, a.id] }
  end

  def display_name
    self.code
  end

  def grp?
    self.account_type.code == 'GRP'
  end

  def reg?
    self.account_type.code == 'REG'
  end

  def enm?
    self.account_type.code == 'ENM'
  end

  def exchange_non_member?
    self.enm?
  end

  def eod_for(date)
    Rails.logger.info "Begun eod for account #{self.code}"

    check_env

    posted_on = date
    posting_date = date

    build_position_nettings(date)

    post_marks(date)

    compute_ote_futures(date)

    build_beginning_balance_ledger_entries(posted_on)

    # cash_movements(currency, seg_code)
    # option_premiums(currency, seg_code)

    build_charge_journal_entries(date)

    build_adjustment_ledger_entry(posting_date)
    build_charge_ledger_entry(posting_date)
    build_pnlfut_ledger_entry(posting_date)

    build_led_balance_ledger_entry(posting_date)

    build_ote_ledger_entry(posting_date)

    build_cash_ledger_entry(posting_date) # cash account balance

    build_liq_balance_ledger_entry(posting_date)

    build_base_balances(posting_date)

    build_statement(date)

    build_statement_summary(date)
    build_statement_summary_2(date)

    # http://www.cmegroup.com/confluence/display/pubspan/Risk+Parameter+File+Layouts+for+the+Positional+Formats
    # ftp://ftp.cmegroup.com/pub/span/data/cme/

    if Rails.env.production? and RuntimeSwitch.is_on?(:send_statement_summary)
      StatementMailer.send_statement('daily_account_statement_summary', self, date).deliver_now
    end

    if Rails.env.production? and RuntimeSwitch.is_on?(:send_statement_summary_2)
      StatementMailer.send_statement('daily_account_statement_summary_2', self, date).deliver_now
    end

    if Rails.env.production? and RuntimeSwitch.is_on?(:send_statement)
      StatementMailer.send_statement('daily_account_statement', self, date).deliver_now
    end

    Rails.logger.info "Ended eod for account #{self.code}"
  end

  def reverse_eod_for(date)
    wipe_statement(date)

    statement_money_lines.stated_on(date).delete_all
    statement_charges.stated_on(date).delete_all
    statement_positions.stated_on(date).delete_all
    statement_position_nettings.stated_on(date).delete_all
    statement_deal_leg_fills.stated_on(date).delete_all

    money_lines.posted_on(date).delete_all

    charges.posted_on(date).delete_all
    adjustments.posted_on(date).delete_all

    journal_entries.posted_on(date).delete_all
    ledger_entries.posted_on(date).delete_all

    uncompute_ote_futures(date)

    Builders::PositionNettingBuilder.break_nettings(self, date)
  end

  def eod_for_group(date)
    Rails.logger.info "Begun eod for account group #{self.code}"
    Rails.logger.info "eod for account group #{self.code} is noop"
    Rails.logger.info "Ended eod for account group #{self.code}"
  end

  def handle_fill(params)
    Rails.logger.info "Calling #{self.class}##{__method__}"
    ActiveRecord::Base.transaction do
      fill = Builders::DealLegFillBuilder.build(params)
      position = Builders::PositionBuilder.build_or_update(fill)
      fill.update(position_id: position.id)
      fill.save!
      fill
    end
  end

  def post_marks(date)
    self.positions.open.posted_on_or_before(date).each do |position|
      claim = position.claim
      frag = "Position ClaimMark for Claim #{claim.code} posted on #{date} for account #{self.code}."
      Rails.logger.info "Seeking #{frag}"
      next if claim.claim_type.code == 'COMBO'
      if claim.claimable.expired?(date)
        Rails.logger.warn "Skipping #{frag}. Claim expired."
        next
      end
      mark = get_claim_mark_for(claim, date)
      position.update_attribute(:mark, mark)
    end
  end

  def get_claim_mark_for(claim, date)
    claim_mark = nil
    frag = "Position ClaimMark for Claim #{claim.code} posted on #{date} for account #{self.code}"
    while true
      Rails.logger.info "Seeking #{frag}."
      claim_mark = claim.claim_marks.posted_on(date).first
      break unless claim_mark.nil?
      Rails.logger.warn "Sleeping seek of #{frag} until #{5.minutes.from_now}."
      sleep 5.minutes
    end
    claim_mark.mark
  end

  def build_position_nettings(date)
    statement_position_nettings.stated_on(date).delete_all
    claim_ids = self.positions.open.pluck(:claim_id).uniq
    claim_ids.each do |claim_id|
      claim = Claim.find(claim_id)
      next if claim.claim_type.code == 'COMBO'
      # positions = self.positions.open.posted_on_or_before(date).with_claim_id(claim_id).order(:id)
      bots = self.positions.bots.open.posted_on_or_before(date).with_claim_id(claim_id).order(:id)
      slds = self.positions.slds.open.posted_on_or_before(date).with_claim_id(claim_id).order(:id)
      Builders::PositionNettingBuilder.build(date, bots, slds)
    end
  end

  def build_statement_positions(date)
    statement_positions.stated_on(date).delete_all
    positions = statement_positions_query(date)
    positions.each do |position|
      position[:stated_on] = date
      Builders::StatementPositionBuilder.build(position)
    end
  end

  def build_statement_deal_leg_fills(date)
    statement_deal_leg_fills.stated_on(date).delete_all
    fills = statement_deal_leg_fills_query(date)
    fills.each do |fill|
      fill[:stated_on] = date.strftime('%Y-%m-%d')
      Builders::StatementDealLegFillBuilder.build(fill)
    end
  end

  def build_statement_position_nettings(date)
    statement_position_nettings.stated_on(date).delete_all
    nettings = statement_position_nettings_query(date)
    nettings.each do |netting|
      netting[:stated_on] = date
      Builders::StatementPositionNettingBuilder.build(netting)
    end
  end

  def build_statement_money_lines(date)
    statement_money_lines.stated_on(date).delete_all
    lines = statement_money_lines_query(date)
    lines.each do |line|
      line[:stated_on] = date
      Builders::StatementMoneyLineBuilder.build(line)
    end
  end

  def build_statement_charges(date)
    statement_charges.stated_on(date).delete_all
    charges = statement_charges_query(date)
    charges.each do |charge|
      charge[:stated_on] = date
      Builders::StatementChargeBuilder.build(charge)
    end
  end

  def build_statement_adjustments(date)
    statement_adjustments.stated_on(date).delete_all
    adjs = statement_adjustments_query(date)
    adjs.each do |adj|
      adj[:stated_on] = date
      Builders::StatementAdjustmentBuilder.build(adj)
    end
  end

  def reverse_ote_futures(date)
    prior_date = journal_entries.ote.maximum(:posted_on)
    entries = journal_entries.ote.posted_on(prior_date)
    entries.each { |entry| Builders::JournalEntryBuilder.reverse(entry, date) }
  end

  def compute_ote_futures(date)
    claim_ids = self.positions.open.pluck(:claim_id).uniq
    claim_ids.each do |claim_id|
      claim = Claim.find(claim_id)
      next if claim.claim_type.code == 'COMBO'
      Rails.logger.info "Computing OTE: #{claim.code}"
      # positions = self.positions.open.with_claim_id(claim_id)
      positions = self.positions.open.posted_on_or_before(date).with_claim_id(claim_id)
      positions.each do |position|
        position.compute_ote(date)
        Builders::JournalEntryBuilder.build_for_ote(position, date)
      end
    end
  end

  def uncompute_ote_futures(date)
    positions.open.where(posted_on: date).each do |position|
      position.update_attribute(:ote, 0)
    end
  end

  def build_charge_journal_entries(date)
    totals = deal_leg_fills.posted_on(date).group(:claim_id).sum("abs(done)")
    totals.each do |total|
      params = {
        account_id: self.id,
        posted_on: date,
        claim_id: total.first,
        done: total.last
      }
      Builders::ChargeBuilder.account_claim_date(params)
    end
  end

  def break_charge_journal_entries(date)
    charges.where(posted_on: date).delete_all
  end

  def build_beginning_balance_ledger_entries(posted_on)
    currency_ids = ledger_entries.pluck(:currency_id).sort.uniq

    currency_ids.each do |currency_id|
      segregation_ids = ledger_entries.for_currency(currency_id).pluck(:segregation_id).sort.uniq
      segregation_ids.each do |segregation_id|
        build_beginning_balance_ledger_entry(posted_on, currency_id, segregation_id)
      end
    end

  end

  def build_beginning_balance_ledger_entry(posted_on, currency_id, segregation_id)
    prior = prior_ledger(posted_on, currency_id, segregation_id)
    amount = prior.blank? ? 0 : prior.amount
    ledger_entry_type = LedgerEntryType.find_by_code('BEG')
    memo = 'automatically generated'
    ledger_entry = Builders::LedgerEntryBuilder.build(self, posted_on, ledger_entry_type, memo, amount, currency_id, segregation_id)
    money_line = Builders::MoneyLineBuilder.build(ledger_entry)
  end

  def build_charge_ledger_entry(posting_date)
    entries = JournalEntry.charges.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('CHG')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_adjustment_ledger_entry(posting_date)
    entries = JournalEntry.adjustments.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('ADJ')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_pnlfut_ledger_entry(posting_date)
    entries = JournalEntry.pnl_futures.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('PNLFUT')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_led_balance_ledger_entry(posting_date)
    entries = LedgerEntry.ledger_components.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('LEG')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_ote_ledger_entry(posting_date)
    entries = JournalEntry.ote.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('OTE')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_cash_ledger_entry(posting_date)
    entries = LedgerEntry.cash_components.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('CSHACT')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_liq_balance_ledger_entry(posting_date)
    entries = LedgerEntry.liquidating_components.posted_on(posting_date).select('currency_id, segregation_id, sum(amount) as amount').where("account_id = ?", self.id).group(:currency_id, :segregation_id)
    entries.each do |entry|
      memo = 'automatically generated'
      ledger_entry_type = LedgerEntryType.find_by_code('LIQ')
      ledger_entry = Builders::LedgerEntryBuilder.build(self, posting_date, ledger_entry_type, memo, entry.amount, entry.currency_id, entry.segregation_id)
      money_line = Builders::MoneyLineBuilder.build(ledger_entry)
    end
  end

  def build_base_balances(posted_on)
    base = money_lines.base.posted_on(posted_on).first
    base.delete unless base.blank?
    base = MoneyLine.new do |b|
      b.account_id = self.id
      b.currency_id = Currency.usd.id
      b.kind = 'BASE'
      b.posted_on = posted_on
      b.beginning_balance = 0
      b.cash = 0
      b.pnl_futures = 0
      b.pnl_options = 0
      b.adjustments = 0
      b.rebates = 0
      b.charges = 0
      b.ledger_balance = 0
      b.open_trade_equity = 0
      b.cash_account_balance = 0
      b.margin = 0
      b.long_option_value = 0
      b.short_option_value = 0
      b.net_option_value = 0
      b.net_liquidating_balance = 0
      b.segregation = Segregation.find_by_code('SEGB')
    end
    money_lines.held.posted_on(posted_on).each do |held|
      mark = held.currency.currency_marks.posted_on(posted_on).first.mark
      held.attributes.keys.each do |key|
        next unless held[key].class == BigDecimal
        next if key.match('currency_mark')
        # accumulate by currency held for each key
        base[key] = base[key] + (held[key] * mark).round(3)
        held.update_attribute(:currency_mark, mark)
      end
    end
    base.save!
    base
  end

  def prior_ledger(posted_on, currency_id, segregation_id)
    ledger_entries.ledger.posted_before(posted_on).for_currency(currency_id).for_segregation(segregation_id).order(posted_on: :desc).limit(1).first
  end

  def statement_deal_leg_fills_query(date)
    sql = "
        SELECT
            account_id,
            account_code,
            claim_code,
            claim_name,
            traded_on,
            posted_on,
            SUM(bot)       AS bot,
            SUM(sld)       AS sld,
            SUM(bot + sld) AS net,
            price,
            price_traded
        FROM
            (
             SELECT
                    a.id   AS account_id,
                    a.code AS account_code,
                    c.code AS claim_code,
                    c.name AS claim_name,
                    f.posted_on,
                    f.traded_on,
                    f.price,
                    f.price_traded,
                    CASE
                        WHEN done > 0
                        THEN done
                        ELSE 0
                    END AS bot,
                    CASE
                        WHEN done < 0
                        THEN done
                        ELSE 0
                    END AS sld
               FROM
                    claims c,
                    accounts a,
                    deal_leg_fills f
              WHERE
                    a.id = f.account_id AND
                    c.id = f.claim_id AND
                    account_id = #{self.id} AND
                    posted_on = \'#{date}\')x
        GROUP BY
            account_id,
            account_code,
            claim_code,
            claim_name,
            traded_on,
            posted_on,
            price,
            price_traded
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def statement_position_nettings_query(date)
    sql = "
      SELECT
          a.id as account_id,
          a.code as account_code,
          c.code as claim_code,
          c.name as claim_name,
          t.code as netting_code,
          posted_on,
          bot_price_traded,
          sld_price_traded,
          done,
          pnl,
          x.code as currency_code
      FROM
          claims c,
          currencies x,
          accounts a,
          position_nettings n,
          position_netting_types t
      WHERE
          a.id = #{self.id} AND
          n.posted_on = \'#{date}\' AND
          c.id = n.claim_id AND
          a.id = n.account_id AND
          x.id = n.currency_id AND
          t.id = n.position_netting_type_id
      ORDER BY
          account_id,
          posted_on,
          claim_id,
          netting_code,
          bot_price_traded,
          sld_price_traded
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def statement_positions_query(date)
    sql = "
      SELECT
          a.id   AS account_id,
          a.code AS account_code,
          c.code AS claim_code,
          c.name AS claim_name,
          p.traded_on,
          p.posted_on,
          p.bot,
          p.sld,
          p.net,
          p.price,
          p.price_traded,
          p.mark,
          p.ote,
          x.code AS currency_code,
          s.code AS position_status_code
      FROM
          claims c,
          accounts a,
          currencies x,
          positions p,
          position_statuses s
      WHERE
          a.id = #{self.id} AND
          p.posted_on <= \'#{date}\' AND
          s.code = 'OPN' AND
          c.id = p.claim_id AND
          a.id = p.account_id AND
          x.id = c.point_currency_id AND
          s.id = p.position_status_id
      ORDER BY
          posted_on,
          account_code,
          claim_code,
          mark
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def statement_money_lines_query(date)
    sql = "
      SELECT
          m.posted_on,
          a.id   AS account_id,
          a.code AS account_code,
          c.code AS currency_code,
          s.code AS segregation_code,
          m.kind,
          m.beginning_balance,
          m.charges,
          m.adjustments,
          m.pnl_futures,
          m.ledger_balance,
          m.open_trade_equity,
          m.cash_account_balance,
          m.net_liquidating_balance,
          m.currency_mark
      FROM
          accounts a,
          currencies c,
          money_lines m,
          segregations s
      WHERE
          a.id = #{self.id} AND
          m.posted_on = \'#{date}\' AND
          a.id = m.account_id AND
          c.id = m.currency_id AND
          s.id = m.segregation_id
      ORDER BY
          account_code,
          m.id
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def statement_charges_query(date)
    sql = "
      SELECT
          f.posted_on,
          f.account_id,
          a.code AS account_code,
          z.code AS charge_code,
          j.code AS journal_code,
          c.code AS currency_code,
          f.amount,
          f.memo
      FROM
          charges f,
          chargeables y,
          chargeable_types z,
          accounts a,
          journals j,
          currencies c,
          journal_entries e,
          journal_entry_types t
      WHERE
          a.id = #{self.id} AND
          t.id = e.journal_entry_type_id AND
          a.id = f.account_id AND
          j.id = e.journal_id AND
          e.id = f.journal_entry_id AND
          c.id = f.currency_id AND
          y.id = f.chargeable_id AND
          z.id = y.chargeable_type_id AND
          f.posted_on = \'#{date}\'
      ORDER BY
          posted_on,
          account_code,
          currency_code
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def statement_adjustments_query(date)
    sql = "
      SELECT
          c.posted_on,
          c.account_id,
          a.code AS account_code,
          t.code AS adjustment_code,
          j.code AS journal_code,
          x.code AS currency_code,
          c.amount,
          c.memo
      FROM
          adjustments c,
          accounts a,
          journals j,
          currencies x,
          journal_entries e,
          journal_entry_types t
      WHERE
          a.id = #{self.id} AND
          t.id = e.journal_entry_type_id AND
          a.id = c.account_id AND
          j.id = e.journal_id AND
          e.id = c.journal_entry_id AND
          x.id = c.currency_id AND
          c.posted_on = \'#{date}\'
      ORDER BY
          posted_on,
          account_code,
          currency_code
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def check_env
    vars = %W(TXT_DIR PDF_DIR)
    vars.each do |var|
      if ENV[var].blank?
        puts "Environment is missing #{var}. Exiting."
        exit
      end
    end
  end

  def build_statement_summary(date)
    base = 'daily_account_statement_summary'

    # order matters
    txt_filename = build_statement_summary_txt(base, date)
    pdf_filename = build_statement_summary_pdf(base, date)

    build_statement_summary_report_txt(base, date, txt_filename)
    build_statement_summary_report_pdf(base, date, pdf_filename)
  end

  def build_statement_summary_2(date)
    base = 'daily_account_statement_summary_2'

    # order matters
    txt_filename = build_statement_summary_2_txt(base, date)
    pdf_filename = build_statement_summary_pdf(base, date)

    build_statement_summary_report_txt(base, date, txt_filename)
    build_statement_summary_report_pdf(base, date, pdf_filename)
  end

  def build_statement_summary_report_txt(base, date, location)
    params = {
      posted_on: date,
      format_type_code: 'TXT',
      report_type_code: base,
      memo: "Daily Account Statement Summary #{code} #{date}",
      location: location
    }
    Builders::ReportBuilder.build(params)
  end

  def build_statement_summary_report_pdf(base, date, location)
    params = {
      posted_on: date,
      format_type_code: 'PDF',
      report_type_code: base,
      memo: "Daily Account Statement Summary #{code} #{date}",
      location: location
    }
    Builders::ReportBuilder.build(params)
  end

  def build_statement(date)
    base = 'daily_account_statement'

    # order matters
    txt_filename = build_statement_txt(base, date)
    pdf_filename = build_statement_pdf(base, date)

    build_statement_report_txt(base, date, txt_filename)
    build_statement_report_pdf(base, date, pdf_filename)
  end

  def build_statement_report_txt(base, date, location)
    params = {
      posted_on: date,
      format_type_code: 'TXT',
      report_type_code: base,
      memo: "Daily Account Statement #{code} #{date}",
      location: location
    }
    Builders::ReportBuilder.build(params)
  end

  def build_statement_report_pdf(base, date, location)
    params = {
      posted_on: date,
      format_type_code: 'PDF',
      report_type_code: base,
      memo: "Daily Account Statement #{code} #{date}",
      location: location
    }
    Builders::ReportBuilder.build(params)
  end

  def build_statement_pdf(base, date)
    txt_filename = build_filename(base, date, 'txt')
    pdf_filename = build_filename(base, date, 'pdf')

    header = "EMM #{self.code} #{date} " + '|%D %C|Page $% of $='
    begin
      system "enscript #{txt_filename} --font=Courier8 --header=\'#{header}\' --landscape -o - | ps2pdf - #{pdf_filename}"
    rescue Exception => e
      msg = "PDF generation exception: #{e.message}"
      Rails.logger.warn(msg)
      EodMailer.status(msg).deliver_now
    end

    pdf_filename
  end

  def build_statement_txt(base, date)
    build_statement_deal_leg_fills(date)
    build_statement_position_nettings(date)
    build_statement_positions(date)
    build_statement_charges(date)
    build_statement_adjustments(date)
    build_statement_money_lines(date)

    txt_filename = build_filename(base, date, 'txt')
    txt_file = File.new(txt_filename, 'w')

    txt_file.write(section_header('Activity'))
    count = 0
    sums = { bot: 0, sld: 0, net: 0 }
    last_fill = nil
    last_claim_code = nil
    statement_deal_leg_fills.stated_on(date).order(:claim_code, :price_traded).each do |fill|
      txt_file.write(fill.to_statement_line_header) if count == 0
      if last_claim_code != fill.claim_code
        txt_file.write(fill.to_statement_line_summary(sums)) if count > 0
        sums = { bot: 0, sld: 0, net: 0 }
        txt_file.write("\n")
      end
      txt_file.write(fill.to_statement_line)
      last_claim_code = fill.claim_code
      sums[:bot] += fill.bot
      sums[:sld] += fill.sld
      sums[:net] += fill.net
      last_fill = fill
      count += 1
    end
    txt_file.write(last_fill.to_statement_line_summary(sums)) unless last_fill.blank?

    txt_file.write("\f")

    txt_file.write(section_header('Netting'))
    count = 0
    sums = { done: 0, pnl: 0 }
    last_netting = nil
    last_claim_code = nil
    statement_position_nettings.stated_on(date).order(:claim_code, :bot_price_traded).each do |netting|
      txt_file.write(netting.to_statement_line_header) if count == 0
      if last_claim_code != netting.claim_code
        txt_file.write(netting.to_statement_line_summary(sums)) if count > 0
        sums = { done: 0, pnl: 0 }
        txt_file.write("\n")
      end
      txt_file.write(netting.to_statement_line)
      last_claim_code = netting.claim_code
      sums[:done] += netting.done
      sums[:pnl] += netting.pnl
      last_netting = netting
      count += 1
    end
    txt_file.write(last_netting.to_statement_line_summary(sums)) unless last_netting.blank?

    txt_file.write("\f")

    txt_file.write(section_header('Positions'))
    count = 0
    sums = { bot: 0, sld: 0, ote: 0 }
    last_position = nil
    last_claim_code = nil
    statement_positions.stated_on(date).order(:claim_code, :price).each do |position|
      txt_file.write(position.to_statement_line_header) if count == 0
      if last_claim_code != position.claim_code
        txt_file.write(position.to_statement_line_summary(sums)) if count > 0
        sums = { bot: 0, sld: 0, ote: 0 }
        txt_file.write("\n")
      end
      txt_file.write(position.to_statement_line)
      last_claim_code = position.claim_code
      sums[:bot] += position.bot
      sums[:sld] += position.sld
      sums[:ote] += position.ote
      last_position = position
      count += 1
    end
    txt_file.write(last_position.to_statement_line_summary(sums)) unless last_position.blank?

    txt_file.write("\f")

    txt_file.write(section_header('Charges'))
    count = 0
    statement_charges.stated_on(date).order(:id).each do |charge|
      txt_file.write(charge.to_statement_line_header) if count == 0
      txt_file.write(charge.to_statement_line)
      count += 1
    end

    txt_file.write("\f")

    # txt_file.write("\f")

    txt_file.write(section_header('Adjustments'))
    count = 0
    statement_adjustments.stated_on(date).order(:id).each do |adjustment|
      txt_file.write(adjustment.to_statement_line_header) if count == 0
      txt_file.write(adjustment.to_statement_line)
      count += 1
    end

    txt_file.write("\f")

    txt_file.write(section_header('Monies'))
    count = 0
    statement_money_lines.stated_on(date).order('kind DESC, currency_code').each do |line|
      txt_file.write(line.to_statement_line_header) if count == 0
      txt_file.write(line.to_statement_line)
      count += 1
    end

    txt_file.close

    txt_filename
  end

  def section_header(name)
    line_len = 147
    work_len = line_len - (name.length + 2)
    head_len = work_len / 2
    tail_len = head_len
    '#' * head_len + " #{name} " + '#' * tail_len + "\n\n"
  end

  def build_filename(base, date, format)
    root = ENV['TXT_DIR'] if format == 'txt'
    root = ENV['PDF_DIR'] if format == 'pdf'
    path = "#{root}/#{date.strftime('%Y%m%d')}"
    FileUtils.mkdir_p path unless Dir.exist? path
    filename = "#{base}_#{code}_#{date.strftime('%Y%m%d')}"
    "#{path}/#{filename}.#{format}"
  end

  def wipe_statement(date)
    BASE_FILE_NAMES.each do |base|
      %W(txt pdf).each do |extension|
        filename = build_filename(base, date, extension)
        begin
          File.delete(filename)
        rescue Exception => e
          puts e.message
        end
      end
    end
  end

  private

  def show_position_claims(positions)
    puts "*" * 20
    positions.each do |p|
      puts "#{p.claim.code} #{p.claim.id}"
    end
    puts "-" * 20
  end

  def build_statement_summary_pdf(base, date)
    build_statement_pdf(base, date)
  end

  def build_statement_summary_txt(base, date)
    txt_filename = build_filename(base, date, 'txt')
    txt_file = File.new(txt_filename, 'w')

    #
    # net liq
    #

    txt_file.write(section_header('Five Day Net Liquidating Balances'))

    results = query_five_day_look_back_net_liqudity(date)
    dates = []
    last = 1
    line = "%10s %10s %10s %10s %5s\n" % ['Account', 'Date', 'Net Liq', 'Change', 'Pct']
    txt_file.write(line)
    results.to_a.reverse.each_with_index do |result, i|
      # {"code"=>"00877", "stated_on"=>"2017-10-25", "net_liquidating_balance"=>"1349746.79"}
      code = result['code']
      date = result['stated_on']
      nbal = BigDecimal(result['net_liquidating_balance'], 2)
      diff = nbal - last
      dpct = (last == 0) ? 0 : ((diff / last) * 100).round(2)
      line = "%10s %10s %10.2f %10.2f %5.2f\n" % [code, date, nbal, diff, dpct]
      txt_file.write(line) if i > 0
      last = nbal
      dates << date
    end
    txt_file.write("\n")

    #
    # positions
    #

    txt_file.write(section_header('Positions'))
    count = 0
    sums = { bot: 0, sld: 0, ote: 0 }
    last_position = nil
    last_claim_code = nil
    statement_positions.stated_on(date).order(:claim_code, :price).each do |position|
      txt_file.write(position.to_statement_line_header) if count == 0
      if last_claim_code != position.claim_code
        txt_file.write(position.to_statement_line_summary(sums)) if count > 0
        sums = { bot: 0, sld: 0, ote: 0 }
        txt_file.write("\n")
      end
      txt_file.write(position.to_statement_line)
      last_claim_code = position.claim_code
      sums[:bot] += position.bot
      sums[:sld] += position.sld
      sums[:ote] += position.ote
      last_position = position
      count += 1
    end
    txt_file.write(last_position.to_statement_line_summary(sums)) unless last_position.blank?
    txt_file.write("\n")

    #
    # money lines
    #

    txt_file.write(section_header('Monies'))

    month_end = (Date.parse(date) - 1.month).end_of_month

    this = statement_money_lines.base.posted_on(date).first
    that = statement_money_lines.base.where("posted_on <= ?", month_end).order("posted_on desc").limit(1).first

    unless this.blank? or that.blank?
      hash = {}
      this_attrs = this.attributes
      that_attrs = that.attributes

      this_attrs.keys.each do |key|
        next if ['id', 'currency_mark'].include?(key)
        if this_attrs[key].is_a?(String) or this_attrs[key].is_a?(Date)
          hash[key] = this_attrs[key]
        else
          hash[key] = this_attrs[key] - that_attrs[key]
        end
      end

      diff = StatementMoneyLine.new(hash)

      txt_file.write(diff.to_statement_line_header)

      [that, this, diff].each_with_index do |line, i|
        line.currency_mark = 1.0
        diff.posted_on = nil if i == 2
        txt_file.write(line.to_statement_line)
      end
    end

    txt_file.close

    txt_filename
  end

  def handle_foo(result, pte_usd_sum)
    out = []

    stated_on = result['stated_on']
    acc_code = result['account_code']
    seg_code = result['segregation_code']
    kind = result['kind']
    ccy = result['currency_code']

    pnl = BigDecimal(result['pnl_futures'], 2)
    adj = BigDecimal(result['adjustments'], 2)
    chg = BigDecimal(result['charges'], 2)
    ote = BigDecimal(result['open_trade_equity'], 2)
    mrk = (result['currency_mark'].blank?) ? 1 : BigDecimal(result['currency_mark'], 2)

    prior_stated_on = self.statement_money_lines.where("stated_on < ?", stated_on).order("stated_on desc").limit(1).pluck(:stated_on).first
    prior_ote = self.statement_money_lines.stated_on(prior_stated_on).where("currency_code = ?", ccy).where("segregation_code = ?", seg_code).pluck(:open_trade_equity).first

    pte = prior_ote.blank? ? 0 : BigDecimal(prior_ote, 2)

    if result['kind'].match('HELD')
      # accumulate HelD
      pte_usd = pte * mrk
      pte_usd_sum += pte_usd
    else
      # apply accumulation to BASE
      pte = pte_usd_sum
    end

    net = pnl + adj + chg + ote - pte

    [[stated_on, acc_code, kind, seg_code, pnl, adj, chg, -1 * pte, ote, net, ccy, mrk], pte_usd_sum]
  end

  def build_statement_summary_2_txt(base, base_date)
    txt_filename = build_filename(base, base_date, 'txt')
    txt_file = File.new(txt_filename, 'w')

    #
    # daily trader pnl
    #

    prior_month_end_date = (base_date - 1.month).end_of_month
    # need last statement date
    prior_month_end_date = self.statement_money_lines.base.where('stated_on <= ?', prior_month_end_date).order('stated_on desc').pluck(:stated_on).first

    txt_file.write(section_header('Daily PnL'))

    count = 0

    if prior_month_end_date
      dates = self.statement_money_lines.base.where("stated_on > ? and stated_on <= ?", prior_month_end_date, base_date).order(:stated_on).pluck(:stated_on)
    else
      c = self.statement_money_lines.base.where("stated_on <= ?", base_date).order(:stated_on).pluck(:stated_on).count
      dates = self.statement_money_lines.base.where("stated_on <= ?", base_date).order(:stated_on).limit([c,5].min).pluck(:stated_on)
    end

    line_format = "%10s %10s %5s %5s %10s %10s %10s %10s %10s %10s %3s %10s\n"
    line_header = ['Stated On', 'Account', 'Kind', 'Seg', 'PnL', 'Adjs', 'Chgs', 'POTE Rev', 'OTE', 'Net', 'CCY', 'Mark']
    page_header = line_format % line_header
    txt_file.write(page_header)
    txt_file.write("\n")

    base_result = {}
    base_result_summed = {}

    line_format = "%10s %10s %5s %5s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %3s %10.6f\n"
    dates.each do |date|
      base_result = nil
      pte_usd_sum = 0
      results = query_trader_pnl_balances_for_date(date)
      results.to_a.each_with_index do |result, i|
        puts result.inspect

        if result['kind'].match(/BASE/)
          base_result = result
          next
        end

        # HELD balances line

        out, pte_usd_sum = handle_foo(result, pte_usd_sum)
        line = line_format % out
        txt_file.write(line)

        count += 1
      end

      # BASE balances line

      out, pte_usd_sum = handle_foo(base_result, pte_usd_sum)
      line = line_format % out
      txt_file.write(line)
      txt_file.write("\n")

      if Date.parse(base_result['stated_on']) != prior_month_end_date
        base_result_summed = sum_base_result(base_result, base_result_summed)
      end

      write_page_header(txt_file, page_header) if count > 40
      count = count > 40 ? 0 : count + 1
    end

    base_result_summed = base_result_summed_ote_fix(base_result, base_result_summed)
    base_result_summed = base_result_summed_write_prep(base_result_summed, prior_month_end_date)

    write_base_result_summed(txt_file, base_result_summed)

    txt_file.write("\f")

    #
    # positions
    #

    txt_file.write(section_header('Positions'))
    count = 0
    sums = { bot: 0, sld: 0, ote: 0 }
    last_position = nil
    last_claim_code = nil
    statement_positions.stated_on(base_date).order(:claim_code, :price).each do |position|
      txt_file.write(position.to_statement_line_header) if count == 0
      if last_claim_code != position.claim_code
        txt_file.write(position.to_statement_line_summary(sums)) if count > 0
        sums = { bot: 0, sld: 0, ote: 0 }
        txt_file.write("\n")
      end
      txt_file.write(position.to_statement_line)
      last_claim_code = position.claim_code
      sums[:bot] += position.bot
      sums[:sld] += position.sld
      sums[:ote] += position.ote
      last_position = position
      count += 1
    end
    txt_file.write(last_position.to_statement_line_summary(sums)) unless last_position.blank?
    txt_file.write("\n")

    txt_file.close

    txt_filename
  end

  def sum_base_result(base_result, base_result_summed)
    if base_result_summed.keys.blank?
      base_result_summed = base_result.dup
      base_result_summed['open_trade_equity'] = 0
      base_result_summed['pnl_futures'] = 0
      base_result_summed['adjustments'] = 0
      base_result_summed['charges'] = 0
    end

    base_result_summed['stated_on'] = base_result['stated_on']
    base_result_summed['pnl_futures'] += BigDecimal(base_result['pnl_futures'], 2)
    base_result_summed['adjustments'] += BigDecimal(base_result['adjustments'], 2)
    base_result_summed['charges'] += BigDecimal(base_result['charges'], 2)

    base_result_summed
  end

  def base_result_summed_ote_fix(base_result, base_result_summed)
    ote = base_result['open_trade_equity'].nil? ? 0 : BigDecimal(base_result['open_trade_equity'], 2)
    base_result_summed['ote'] = ote
    base_result_summed
  end

  def base_result_summed_net_fix(prior_month_end_date, base_result_summed)
    result = self.statement_money_lines.base.stated_on(prior_month_end_date).order(stated_on: :desc).first
    ote = (result.nil?) ? 0 : BigDecimal(result['open_trade_equity'], 2)
    base_result_summed['net'] = base_result_summed['net'] - ote
    base_result_summed
  end

  def base_result_summed_write_prep(base_result_summed, prior_month_end_date)
    base_result_summed['label'] = 'Total'
    base_result_summed['pte'] = ''

    # if values nil then BigDecimal pitches a fit.

    pnl_futures = base_result_summed['pnl_futures'].nil? ? 0 : BigDecimal(base_result_summed['pnl_futures'], 2)
    adjustments = base_result_summed['adjustments'].nil? ? 0 : BigDecimal(base_result_summed['adjustments'], 2)
    charges = base_result_summed['charges'].nil? ? 0 : BigDecimal(base_result_summed['charges'], 2)
    ote = base_result_summed['ote'].nil? ? 0 : BigDecimal(base_result_summed['ote'], 2)

    base_result_summed['net'] = [pnl_futures, adjustments, charges, ote].map { |x| BigDecimal(x, 2) }.sum

    # base_result_summed['net'] = (%W(pnl_futures adjustments charges ote).map {|key| BigDecimal(base_result_summed[key])}).sum

    base_result_summed_net_fix(prior_month_end_date, base_result_summed)
  end

  def write_page_header(txt_file, page_header)
    txt_file.write("\f")
    txt_file.write(page_header)
    txt_file.write("\n")
  end

  def write_base_result_summed(txt_file, base_result_summed)
    keys = %W(stated_on account_code kind segregation_code  pnl_futures adjustments charges pte ote net currency_code label)

    line_format = "%10s %10s %5s %5s %10.2f %10.2f %10.2f %10s %10.2f %10.2f %3s %10s\n"
    line_output = keys.map { |key| base_result_summed[key].nil? ? 0 : base_result_summed[key] }

    txt_file.write(line_format % line_output)
    txt_file.write("\n")
  end

  def query_five_day_look_back_net_liqudity(date)
    sql = "
      SELECT
          a.code,
          l.stated_on,
          l.net_liquidating_balance
      FROM
          statement_money_lines l,
          accounts a
      WHERE
          kind = 'BASE' AND
          l.stated_on <= \'#{date}\' AND
          a.code = \'#{self.code}\' AND
          a.id = l.account_id
      ORDER BY
          l.stated_on DESC limit 6
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def query_trader_pnl_balances_for_date(date)
    # dealing with a bug in which a balance could be HELD and SEGB.
    sql = "
      SELECT
          stated_on,
          account_code,
          kind,
          segregation_code,
          pnl_futures,
          adjustments,
          charges,
          open_trade_equity,
          currency_code,
          currency_mark
      FROM
          statement_money_lines m,
          segregations s
      WHERE
          s.code = m.segregation_code AND
          account_code = \'#{self.code}\' AND
          stated_on = \'#{date}\' AND
          NOT (s.code = 'SEGB' AND m.kind = 'HELD')
      ORDER BY currency_code
      "

    ActiveRecord::Base.connection.execute(sql)
  end

end
