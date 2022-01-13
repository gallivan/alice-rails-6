# == Schema Information
#
# Table name: journal_entries
#
#  id                    :integer          not null, primary key
#  journal_id            :integer          not null
#  journal_entry_type_id :integer          not null
#  account_id            :integer          not null
#  currency_id           :integer          not null
#  posted_on             :date             not null
#  as_of_on              :date             not null
#  amount                :decimal(, )      not null
#  memo                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  segregation_id        :integer          not null
#

class JournalEntry < ApplicationRecord
  validates :journal_id, presence: true
  validates :journal_entry_type_id, presence: true

  validates :account_id, presence: true
  validates :currency_id, presence: true

  validates :posted_on, presence: true
  validates :as_of_on, presence: true
  validates :amount, presence: true
  validates :memo, presence: true

  belongs_to :journal
  belongs_to :journal_entry_type

  belongs_to :account
  belongs_to :currency
  belongs_to :segregation

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

  scope :charges, -> {
    joins(:journal_entry_type).
        where("journal_entry_types.code in ('COM', 'FEE')")
  }

  scope :adjustments, -> {
    joins(:journal_entry_type).
        where("journal_entry_types.code = 'ADJ'")
  }

  scope :pnl_futures, -> {
    joins(:journal_entry_type).
        where("journal_entry_types.code = 'PNL'")
  }

  scope :ote, -> {
    joins(:journal_entry_type).
        where("journal_entry_types.code = 'OTE'")
  }

end
