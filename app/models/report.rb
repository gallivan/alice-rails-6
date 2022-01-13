# == Schema Information
#
# Table name: reports
#
#  id             :integer          not null, primary key
#  report_type_id :integer
#  format_type_id :integer
#  memo           :string
#  location       :string
#  posted_on      :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Report < ApplicationRecord
  validates :report_type, presence: true
  validates :format_type, presence: true

  belongs_to :report_type
  belongs_to :format_type

  before_destroy do
    File.unlink self.location if File.exists? self.location
  end

end
