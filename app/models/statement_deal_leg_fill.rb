# == Schema Information
#
# Table name: statement_deal_leg_fills
#
#  id           :integer          not null, primary key
#  account_id   :integer
#  account_code :string
#  claim_code   :string
#  claim_name   :string
#  stated_on    :date
#  posted_on    :date
#  traded_on    :date
#  bot          :decimal(, )
#  sld          :decimal(, )
#  net          :decimal(, )
#  price        :decimal(, )
#  price_traded :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class StatementDealLegFill < ApplicationRecord
  validates :account_id, presence: true
  validates :account_code, presence: true
  validates :claim_code, presence: true
  validates :stated_on, presence: true
  validates :posted_on, presence: true
  validates :traded_on, presence: true
  validates :bot, presence: true
  validates :sld, presence: true
  validates :net, presence: true
  validates :price, presence: true
  validates :price_traded, presence: true

  belongs_to :account

  scope :stated_on, -> (date) { where(stated_on: date) }
  scope :traded_on, -> (date) { where(traded_on: date) }
  scope :posted_on, -> (date) { where(posted_on: date) }

  def to_statement_line_header
    "%10s %10s %10s %+60s %8s %8s %8s %12s %12s\n" % %W(Posted Traded Account Claim Bot Sld Net Traded Decimal)
  end

  def to_statement_line_summary(sums)
    "%10s %10s %10s %+60s %8s %8s %8s %12s\n" % [ '', '', '', '', sums[:bot].to_i, sums[:sld].abs.to_i, sums[:net].to_i, '' ]
  end

  def to_statement_line
    "%10s %10s %10s %+60s %8s %8s %8s %12s %12.7f\n" % [posted_on, traded_on, account_code, claim_name, bot.to_i, sld.abs.to_i, net.to_i, price_traded, price]
  end
end
