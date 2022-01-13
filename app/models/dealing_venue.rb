# == Schema Information
#
# Table name: dealing_venues
#
#  id                    :integer          not null, primary key
#  entity_id             :integer          not null
#  dealing_venue_type_id :integer          not null
#  code                  :string           not null
#  name                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class DealingVenue < ApplicationRecord
  validates :entity, presence: true
  validates :dealing_venue_type_id, presence: true
  validates :code, presence: true
  validates :name, presence: true

  belongs_to :entity
  belongs_to :dealing_venue_type

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
