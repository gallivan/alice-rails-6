# == Schema Information
#
# Table name: entities
#
#  id             :integer          not null, primary key
#  entity_type_id :integer          not null
#  code           :string           not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Entity < ApplicationRecord
  validates :entity_type_id, presence: true
  validates :code, presence: true
  validates :name, presence: true

  belongs_to :entity_type
  has_many :roles, through: :entity_roles
  has_many :accounts
  has_many :clearing_venues
  has_many :dealing_venues
  has_many :systems
  has_many :claims

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
