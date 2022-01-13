# == Schema Information
#
# Table name: ledgers
#
#  id             :integer          not null, primary key
#  ledger_type_id :integer          not null
#  code           :string           not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Ledger < ApplicationRecord
  validates :ledger_type_id, presence: true

  validates :code, presence: true
  validates :name, presence: true

  belongs_to :ledger_type
  has_many :ledger_entries
end
