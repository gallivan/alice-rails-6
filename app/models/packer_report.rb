# == Schema Information
#
# Table name: packer_reports
#
#  id         :integer          not null, primary key
#  posted_on  :date             not null
#  kind       :string           not null
#  fate       :string           not null
#  data       :text             not null
#  goof_error :text
#  goof_trace :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  root       :string
#

class PackerReport < ApplicationRecord
  validates :posted_on, presence: true
  validates :kind, presence: true
  validates :fate, presence: true
  validates :data, presence: true

  scope :todo, -> { where(fate: 'TODO') }
  scope :redo, -> { where(fate: 'REDO') }
  scope :done, -> { where(fate: 'DONE') }
  scope :fail, -> { where(fate: 'FAIL') }

  scope :eod_cme, -> {where(root: 'EOD_CME')}
  scope :itd_abn, -> {where(root: 'ITD_ABN')}

  scope :posted_on, -> (posted_on) { where(posted_on: posted_on) }

  def self.do_redo(report)
    report.update_attributes(goof_error: nil, goof_trace: nil )

    if report.root == 'ITD_ABN'
      picker = Workers::PickerOfItdAbn.new
      picker.resend_report(report)
    elsif report.root == 'EOD_CME'
      picker = Workers::PickerOfEodCme.new
      picker.resend_report(report)
    else
      raise "PackerReport.do_redo failed for PackerReport #{report.id}. Unexpected data content."
    end

  end

  def self.rehandle_message(packer_report)

  end

end
