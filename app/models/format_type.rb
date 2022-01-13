# == Schema Information
#
# Table name: format_types
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FormatType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :reports
end
