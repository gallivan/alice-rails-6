# == Schema Information
#
# Table name: report_types
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :reports
  has_many :report_type_report_type_parameters, dependent: :delete_all
  has_many :report_type_parameters, through: :report_type_report_type_parameters, dependent: :delete_all

  def to_s
    self.handle
  end

end
