# == Schema Information
#
# Table name: report_type_report_type_parameters
#
#  id                       :integer          not null, primary key
#  report_type_id           :integer          not null
#  report_type_parameter_id :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ReportTypeReportTypeParameter < ApplicationRecord
  validates :report_type, presence: true
  validates :report_type_parameter, presence: true

  belongs_to :report_type
  belongs_to :report_type_parameter
end
