# == Schema Information
#
# Table name: claim_set_aliases
#
#  id           :integer          not null, primary key
#  system_id    :integer          not null
#  claim_set_id :integer          not null
#  code         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ClaimSetAlias < ApplicationRecord
  validates :system_id, presence: true
  validates :claim_set_id, presence: true
  validates :code, presence: true

  belongs_to :system
  belongs_to :claim_set
end
