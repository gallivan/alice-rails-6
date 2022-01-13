# == Schema Information
#
# Table name: journal_entry_types
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class JournalEntryType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :journal_entries

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
