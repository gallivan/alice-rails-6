# == Schema Information
#
# Table name: claim_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ClaimType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :claims
end
