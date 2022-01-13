# == Schema Information
#
# Table name: monies
#
#  id           :integer          not null, primary key
#  claimable_id :integer
#  currency_id  :integer          not null
#  settled_on   :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Money < ApplicationRecord
  self.table_name = 'monies'

  validates :settled_on, presence: true
  validates :currency_id, presence: true
  # validates :claimable_id, presence: true

  belongs_to :currency
  has_one :claim, as: :claimable

  def self.next_weekday(date)
    if date.wday == 0
      date + 1.week + 1.day
    elsif date.wday == 6
      date + 1.week + 2.day
    else
      date + 1.week
    end
  end
end
