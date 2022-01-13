# == Schema Information
#
# Table name: entity_roles
#
#  id         :integer          not null, primary key
#  entity_id  :integer          not null
#  role_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EntityRole < ApplicationRecord
  validates :entity_id, presence: true
  validates :role_id, presence: true

  belongs_to :entities
  belongs_to :roles
end
