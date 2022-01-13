# == Schema Information
#
# Table name: position_netting_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PositionNettingType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true
end
