# == Schema Information
#
# Table name: ledger_entry_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LedgerEntryType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :ledger_entries
end
