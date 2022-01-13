# == Schema Information
#
# Table name: statement_money_lines
#
#  id                      :integer          not null, primary key
#  stated_on               :date
#  posted_on               :date
#  account_id              :integer
#  account_code            :string
#  currency_code           :string
#  kind                    :string
#  beginning_balance       :decimal(, )
#  pnl_futures             :decimal(, )
#  ledger_balance          :decimal(, )
#  open_trade_equity       :decimal(, )
#  cash_account_balance    :decimal(, )
#  net_liquidating_balance :decimal(, )
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  currency_mark           :decimal(, )
#  adjustments             :decimal(, )
#  segregation_code        :string           not null
#  charges                 :decimal(, )
#

class StatementMoneyLine < ApplicationRecord
  validates :posted_on, presence: true
  validates :stated_on, presence: true
  validates :beginning_balance, presence: true
  validates :net_liquidating_balance, presence: true

  scope :since, -> (date) { where("stated_on >= ?", date) }
  scope :stated_on, -> (date) { where(stated_on: date) }
  scope :traded_on, -> (date) { where(traded_on: date) }
  scope :posted_on, -> (date) { where(posted_on: date) }
  scope :held, -> { where(kind: 'HELD') }
  scope :base, -> { where(kind: 'BASE') }

  belongs_to :account

  def self.kind_select_options
    %w( BASE HELD )
  end

  def self.currency_code_select_options
    codes = []
    Currency.select(:code).order(:code).each { |currency| codes << currency.code }
    codes
  end

  def to_statement_line_header
    attrs = %W(Posted Account CCY Seg Kind Begin Charges Adj PnL Ledger OTE Cash Net Mark)
    "%10s %10s %3s %4s %4s %10s %10s %10s %10s %10s %10s %10s %10s %11s\n" % attrs
  end

  def to_statement_line
    attrs = [posted_on, account_code, currency_code, segregation_code, kind, beginning_balance, charges, adjustments]
    attrs << [pnl_futures, ledger_balance, open_trade_equity, cash_account_balance, net_liquidating_balance]
    attrs << [currency_mark]
    attrs = attrs.flatten

    if currency_mark.blank?
      "%10s %10s %3s %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f\n" % attrs
    else
      "%10s %10s %3s %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %11.6f\n" % attrs
    end
  end
end
