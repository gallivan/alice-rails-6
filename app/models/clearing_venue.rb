# == Schema Information
#
# Table name: clearing_venues
#
#  id                     :integer          not null, primary key
#  entity_id              :integer          not null
#  clearing_venue_type_id :integer          not null
#  code                   :string           not null
#  name                   :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ClearingVenue < ApplicationRecord
  validates :entity, presence: true
  validates :clearing_venue_type, presence: true
  validates :code, presence: true
  validates :name, presence: true

  belongs_to :entity
  belongs_to :clearing_venue_type
end
