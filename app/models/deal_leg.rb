# == Schema Information
#
# Table name: deal_legs
#
#  id         :integer          not null, primary key
#  deal_id    :integer          not null
#  claim_id   :integer          not null
#  sort       :integer
#  todo       :decimal(, )      not null
#  done       :decimal(, )
#  todo_price :decimal(, )
#  done_price :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DealLeg < ApplicationRecord
  validates :deal_id, presence: true
  validates :claim_id, presence: true
  validates :todo, presence: true
  validates :todo_price, presence: true

  belongs_to :claim
  belongs_to :deal
  has_many :deal_leg_fills
end
