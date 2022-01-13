# == Schema Information
#
# Table name: adjustment_types
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdjustmentType < ApplicationRecord
  validates_presence_of :code, presence: true
  validates_presence_of :name, presence: true

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
