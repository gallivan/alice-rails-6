# == Schema Information
#
# Table name: deal_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DealType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true
end
