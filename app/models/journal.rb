# == Schema Information
#
# Table name: journals
#
#  id              :integer          not null, primary key
#  journal_type_id :integer          not null
#  code            :string           not null
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Journal < ApplicationRecord
  validates :journal_type_id, presence: true

  validates :code, presence: true
  validates :name, presence: true

  belongs_to :journal_type

  has_many :journal_entries

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
