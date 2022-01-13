# == Schema Information
#
# Table name: deals
#
#  id           :integer          not null, primary key
#  deal_type_id :integer          not null
#  account_id   :integer          not null
#  posted_on    :date             not null
#  traded_on    :date             not null
#  todo         :decimal(, )      not null
#  done         :decimal(, )
#  todo_price   :decimal(, )      not null
#  done_price   :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Deal < ApplicationRecord
  validates :account_id, presence: true
  validates :deal_type_id, presence: true
  validates :account_id, presence: true
  validates :posted_on, presence: true
  validates :traded_on, presence: true
  validates :todo, presence: true
  validates :todo_price, presence: true

  belongs_to :account
  belongs_to :deal_type
  has_many :deal_legs
end
