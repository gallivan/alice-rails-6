# == Schema Information
#
# Table name: report_type_parameters
#
#  id         :integer          not null, primary key
#  handle     :string           not null
#  bucket     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportTypeParameter < ApplicationRecord
  validates :handle, presence: true
  validates :bucket, presence: true

  belongs_to :report_type_report_type_parameter

  def to_s
    self.handle
  end

end
