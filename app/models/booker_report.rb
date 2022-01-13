# == Schema Information
#
# Table name: booker_reports
#
#  id         :integer          not null, primary key
#  posted_on  :date
#  kind       :string           not null
#  fate       :string           not null
#  data       :text             not null
#  goof_error :text
#  goof_trace :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  root       :string
#

class BookerReport < ApplicationRecord
  validates :posted_on, presence: true
  validates :kind, presence: true
  validates :fate, presence: true
  validates :data, presence: true

  scope :todo, -> { where(fate: 'TODO') }
  scope :redo, -> { where(fate: 'REDO') }
  scope :done, -> { where(fate: 'DONE') }
  scope :fail, -> { where(fate: 'FAIL') }

  scope :eod_cme, -> {where(root: 'EOD_CME')}
  scope :eod_ghf, -> {where(root: 'EOD_GHF')}

  scope :posted_on, -> (posted_on) { where(posted_on: posted_on) }
end
