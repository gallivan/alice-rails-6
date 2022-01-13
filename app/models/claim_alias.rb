# == Schema Information
#
# Table name: claim_aliases
#
#  id         :integer          not null, primary key
#  system_id  :integer          not null
#  claim_id   :integer          not null
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ClaimAlias < ApplicationRecord
  validates :system_id, presence: true
  validates :claim_id, presence: true
  validates :code, presence: true

  belongs_to :system
  belongs_to :claim
end
