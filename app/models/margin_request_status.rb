# == Schema Information
#
# Table name: margin_request_statuses
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MarginRequestStatus < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :margin_requests
end
