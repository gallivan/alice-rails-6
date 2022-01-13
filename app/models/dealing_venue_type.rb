# == Schema Information
#
# Table name: dealing_venue_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DealingVenueType < ApplicationRecord
  validates_presence_of :code, presence: true
  validates_presence_of :name, presence: true
end
