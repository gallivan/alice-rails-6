# == Schema Information
#
# Table name: ledger_types
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LedgerType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :ledgers
end
