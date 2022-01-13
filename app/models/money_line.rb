# == Schema Information
#
# Table name: money_lines
#
#  id                      :integer          not null, primary key
#  account_id              :integer          not null
#  currency_id             :integer          not null
#  posted_on               :date             not null
#  beginning_balance       :decimal(, )      default(0.0), not null
#  cash                    :decimal(, )      default(0.0), not null
#  fees                    :decimal(, )      default(0.0), not null
#  commissions             :decimal(, )      default(0.0), not null
#  pnl_futures             :decimal(, )      default(0.0), not null
#  pnl_options             :decimal(, )      default(0.0), not null
#  adjustments             :decimal(, )      default(0.0), not null
#  rebates                 :decimal(, )      default(0.0), not null
#  charges                 :decimal(, )      default(0.0), not null
#  ledger_balance          :decimal(, )      default(0.0), not null
#  open_trade_equity       :decimal(, )      default(0.0), not null
#  cash_account_balance    :decimal(, )      default(0.0), not null
#  margin                  :decimal(, )      default(0.0), not null
#  long_option_value       :decimal(, )      default(0.0), not null
#  short_option_value      :decimal(, )      default(0.0), not null
#  net_option_value        :decimal(, )      default(0.0), not null
#  net_liquidating_balance :decimal(, )      default(0.0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  kind                    :string
#  currency_mark           :decimal(, )
#  segregation_id          :integer          not null
#

class MoneyLine < ApplicationRecord
  validates :posted_on, presence: true
  validates :account_id, presence: true
  validates :currency_id, presence: true
  validates :kind, presence: true
  validates :beginning_balance, presence: true
  validates :cash, presence: true
  validates :pnl_futures, presence: true
  validates :pnl_options, presence: true
  validates :adjustments, presence: true
  validates :rebates, presence: true
  validates :charges, presence: true
  validates :ledger_balance, presence: true
  validates :open_trade_equity, presence: true
  validates :cash_account_balance, presence: true
  validates :margin, presence: true
  validates :long_option_value, presence: true
  validates :short_option_value, presence: true
  validates :net_option_value, presence: true
  validates :net_liquidating_balance, presence: true

  belongs_to :account
  belongs_to :currency, class_name: 'Currency'
  belongs_to :segregation

  scope :for_account, ->(account_id) {
    where("account_id = ?", account_id)
  }

  scope :posted_on, ->(posted_on) {
    where("posted_on = ?", posted_on)
  }

  scope :posted_before, ->(posted_on) {
    where("posted_on < ?", posted_on)
  }

  scope :posted_after, ->(posted_on) {
    where("posted_on > ?", posted_on)
  }

  scope :currency, ->(currency_id) {
    where("currency_id = ?", currency_id)
  }

  scope :segregation, ->(segregation_id) {
    where("segregation_id = ?", segregation_id)
  }

  scope :base, -> {
    where("kind = ?", 'BASE')
  }

  scope :held, -> {
    where("kind = ?", 'HELD')
  }

  def is_held?
    kind == 'HELD' ? true : false
  end

  def is_base?
    kind == 'BASE' ? true : false
  end

end
