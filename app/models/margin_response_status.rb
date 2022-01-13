# == Schema Information
#
# Table name: margin_response_statuses
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MarginResponseStatus < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :margin_responses
end
