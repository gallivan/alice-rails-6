# == Schema Information
#
# Table name: charges
#
#  id               :integer          not null, primary key
#  account_id       :integer          not null
#  chargeable_id    :integer          not null
#  currency_id      :integer          not null
#  segregation_id   :integer          not null
#  amount           :decimal(, )      not null
#  memo             :string           not null
#  posted_on        :date             not null
#  as_of_on         :date             not null
#  journal_entry_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Charge < ApplicationRecord
  validates :account_id, presence: true
  validates :amount, presence: true
  validates :currency_id, presence: true
  validates :posted_on, presence: true
  validates :as_of_on, presence: true

  belongs_to :account
  belongs_to :currency
  belongs_to :chargeable
  belongs_to :journal_entry
  belongs_to :segregation

  scope :for_account, -> (account_id) { where(account_id: account_id) }
  scope :posted_on, -> (posted_on) { where(posted_on: posted_on) }

  scope :memo_includes, ->(search) {
    current_scope = self
    search.split.uniq.each do |word|
      current_scope = current_scope.where('memo ILIKE ?', "%#{word}%")
    end
    current_scope
  }

  def self.ransackable_scopes(auth_object = nil)
    [:memo_includes]
  end

  def is_clearing?
    chargeable.chargeable_type.code == 'CLR'
  end

  def is_exchange?
    chargeable.chargeable_type.code == 'EXG'
  end

  def is_service?
    chargeable.chargeable_type.code == 'SRV'
  end

  def is_brokerage?
    chargeable.chargeable_type.code == 'BRK'
  end
end
