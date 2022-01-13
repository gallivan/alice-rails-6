# == Schema Information
#
# Table name: entity_aliases
#
#  id         :integer          not null, primary key
#  system_id  :integer
#  entity_id  :integer
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EntityAlias < ApplicationRecord
  validates :system_id, presence: true
  validates :entity_id, presence: true
  validates :code, presence: true

  belongs_to :system
  belongs_to :entity
end
