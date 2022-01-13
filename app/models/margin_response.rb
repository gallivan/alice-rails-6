# == Schema Information
#
# Table name: margin_responses
#
#  id                        :integer          not null, primary key
#  margin_request_id         :integer
#  margin_response_status_id :integer
#  body                      :string
#  fail                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  posted_on                 :date
#

class MarginResponse < ApplicationRecord
  validates :margin_request_id, presence: true
  validates :margin_response_status, presence: true
  # validates :posted_on, presence: true

  belongs_to :margin_request
  belongs_to :margin_response_status

  def self.build(margin_request, posted_on)
    MarginResponse.create! do |r|
      r.margin_request = margin_request
      r.margin_response_status = MarginResponseStatus.find_by_code('OPEN')
      r.posted_on = posted_on
    end
  end

  def error?
    body.blank? ? false : body.match(/status="ERROR"/)
  end

  def success?
    body.blank? ? false : body.match(/status="SUCCESS"/)
  end

  def processing?
    body.blank? ? false : body.match(/status="PROCESSING"/)
  end

end
