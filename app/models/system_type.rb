# == Schema Information
#
# Table name: system_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SystemType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :systems

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
