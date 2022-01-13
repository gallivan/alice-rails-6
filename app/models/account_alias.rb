# == Schema Information
#
# Table name: account_aliases
#
#  id         :integer          not null, primary key
#  system_id  :integer          not null
#  account_id :integer          not null
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AccountAlias < ApplicationRecord
  validates :system_id, presence: true
  validates :account_id, presence: true
  validates :code, presence: true

  belongs_to :system
  belongs_to :account
end
