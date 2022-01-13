# == Schema Information
#
# Table name: position_statuses
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PositionStatus < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [" #{a.code}", a.id] }
  end
end
