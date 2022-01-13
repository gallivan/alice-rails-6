# == Schema Information
#
# Table name: ledger_entries
#
#  id                   :integer          not null, primary key
#  ledger_id            :integer          not null
#  ledger_entry_type_id :integer          not null
#  account_id           :integer          not null
#  currency_id          :integer          not null
#  posted_on            :date             not null
#  as_of_on             :date             not null
#  amount               :decimal(, )      not null
#  memo                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  segregation_id       :integer          not null
#

class LedgerEntry < ApplicationRecord
  validates :ledger_id, presence: true
  validates :ledger_entry_type_id, presence: true

  validates :account_id, presence: true
  validates :currency_id, presence: true

  validates :posted_on, presence: true
  validates :as_of_on, presence: true
  validates :amount, presence: true
  validates :memo, presence: true

  belongs_to :ledger
  belongs_to :ledger_entry_type

  belongs_to :account
  belongs_to :currency
  belongs_to :segregation

  scope :beginning, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'BEG'")
  }

  scope :charges, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'CHG'")
  }

  scope :pnl_future, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'PNLFUT'")
  }

  scope :ledger_components, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code in ('BEG', 'CHG', 'ADJ', 'PNLFUT')")
  }

  scope :ledger, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'LEG'")
  }

  scope :ote, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'OTE'")
  }

  scope :cash_components, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code in ('LEG', 'OTE')")
  }

  scope :cash, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'CSH'")
  }

  scope :liquidating_components, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'CSHACT'")
  }

  scope :liquidating, -> {
    joins(:ledger_entry_type).
        where("ledger_entry_types.code = 'LIQ'")
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

  scope :for_currency, ->(currency_id) {
    where("currency_id = ?", currency_id)
  }

  scope :for_segregation, ->(segregation_id) {
    where("segregation_id = ?", segregation_id)
  }

  scope :zero_amount, -> {
    where("amount == 0")
  }

end
