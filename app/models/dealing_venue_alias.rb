# == Schema Information
#
# Table name: dealing_venue_aliases
#
#  id               :integer          not null, primary key
#  dealing_venue_id :integer          not null
#  system_id        :integer          not null
#  code             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DealingVenueAlias < ApplicationRecord
  validates :dealing_venue_id, presence: true
  validates :system_id, presence: true
  validates :code, presence: true

  belongs_to :dealing_venue
  belongs_to :system
end
