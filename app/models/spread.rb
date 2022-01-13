# == Schema Information
#
# Table name: spreads
#
#  id           :bigint           not null, primary key
#  claimable_id :integer
#  code         :string           not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Spread < ApplicationRecord
  has_one :claim, as: :claimable, dependent: :destroy
  has_many :spread_legs
end
