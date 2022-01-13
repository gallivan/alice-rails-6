# == Schema Information
#
# Table name: margin_requests
#
#  id                       :integer          not null, primary key
#  margin_id                :integer
#  margin_request_status_id :integer
#  body                     :string
#  fail                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  posted_on                :date
#



class MarginRequest < ApplicationRecord
  validates :margin_id, presence: true
  validates :margin_request_status, presence: true
  # validates :posted_on, presence: true

  belongs_to :margin
  belongs_to :margin_request_status
  has_one :margin_response

  def self.build(margin, posted_on)
    MarginRequest.create! do |x|
      x.margin_id = margin.id
      x.margin_request_status = MarginRequestStatus.find_by_code 'OPEN'
      x.posted_on = posted_on
    end
  end

end
