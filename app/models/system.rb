# == Schema Information
#
# Table name: systems
#
#  id             :integer          not null, primary key
#  entity_id      :integer          not null
#  system_type_id :integer          not null
#  code           :string           not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class System < ApplicationRecord
  validates :entity_id, presence: true
  validates :system_type_id, presence: true
  validates :code, presence: true
  validates :name, presence: true

  belongs_to :entity
  belongs_to :system_type
  has_many :dealing_venue_aliases

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end

  # todo why is this here?
  def select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
