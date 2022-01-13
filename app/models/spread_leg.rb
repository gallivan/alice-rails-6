# == Schema Information
#
# Table name: spread_legs
#
#  id         :bigint           not null, primary key
#  spread_id  :bigint
#  claim_id   :bigint
#  weight     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SpreadLeg < ApplicationRecord
  validates :spread_id, presence: true
  validates :claim_id, presence: true
  validates :weight, presence: true

  belongs_to :spread
  belongs_to :claim
end
