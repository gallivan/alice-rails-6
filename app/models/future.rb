# == Schema Information
#
# Table name: futures
#
#  id                :integer          not null, primary key
#  claimable_id      :integer
#  expires_on        :date             not null
#  code              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  first_holding_on  :date
#  first_intent_on   :date
#  first_delivery_on :date
#  last_trade_on     :date
#  last_intent_on    :date
#  last_delivery_on  :date
#

class Future < ApplicationRecord
  # validates :claimable_id, presence: true
  validates :expires_on, presence: true

  has_one :claim, as: :claimable, dependent: :destroy

  has_many :positions, through: :claim

  scope :expired, -> (date) { where("expires_on < ?", date) }
  scope :expiring, -> (date) { where("expires_on = ?", date) }
  scope :expired_or_expiring, -> (date) { where("expires_on <= ?", date) }
  scope :expiring_within_days, -> (n) { where("expires_on >= ? and expires_on <= ?", Date.today, n.days.from_now) }

  def expired?(date)
    expires_on < date
  end

  def expiring?(date)
    expires_on == date
  end

  def self.on_the_board
    where("expires_on > ?", Date.today)
  end

  def self.expiring
    where("expires_on = ?", Date.today)
  end

  def self.off_the_board
    where("expires_on < ?", Date.today)
  end

end
