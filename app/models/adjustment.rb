# == Schema Information
#
# Table name: adjustments
#
#  id                 :integer          not null, primary key
#  account_id         :integer
#  adjustment_type_id :integer
#  journal_entry_id   :integer
#  amount             :decimal(, )
#  currency_id        :integer
#  posted_on          :date
#  memo               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  segregation_id     :integer          not null
#  as_of_on           :date
#

class Adjustment < ApplicationRecord
  validates :account_id, presence: true
  validates :currency_id, presence: true
  validates :adjustment_type_id, presence: true
  validates :amount, presence: true
  validates :posted_on, presence: true
  validates :memo, presence: true

  belongs_to :account
  belongs_to :currency
  belongs_to :journal_entry
  belongs_to :adjustment_type
  belongs_to :segregation

  scope :for_account, -> (account_id) {where(account_id: account_id)}
  scope :posted_on, -> (posted_on) {where(posted_on: posted_on)}

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

end
