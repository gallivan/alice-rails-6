# == Schema Information
#
# Table name: statement_positions
#
#  id                   :integer          not null, primary key
#  account_id           :integer          not null
#  account_code         :string           not null
#  claim_code           :string           not null
#  claim_name           :string           not null
#  stated_on            :date             not null
#  posted_on            :date             not null
#  traded_on            :date             not null
#  bot                  :decimal(, )      not null
#  sld                  :decimal(, )      not null
#  net                  :decimal(, )      not null
#  price                :decimal(, )      not null
#  mark                 :decimal(, )      not null
#  ote                  :decimal(, )      not null
#  currency_code        :string           not null
#  position_status_code :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  price_traded         :string
#

class StatementPosition < ApplicationRecord
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
  validates :mark, presence: true
  validates :ote, presence: true
  validates :currency_code, presence: true
  validates :position_status_code, presence: true

  belongs_to :account

  scope :stated_on, -> (date) { where(stated_on: date) }
  scope :traded_on, -> (date) { where(traded_on: date) }
  scope :posted_on, -> (date) { where(posted_on: date) }

  scope :claim_code, -> (claim_code) {where(claim_code: claim_code)}

  def to_statement_line_header
    "%10s %10s %10s %+50s %6s %6s %6s %12s %12s %12s %3s\n" % %W(Posted Traded Account Claim Bot Sld Net Price Mark OTE CCY)
  end

  def to_statement_line_summary(sums)
    "%10s %10s %10s %+50s %6d %6d %6d %12s %12s %12.2f %3s\n" % ['', '', '', '', sums[:bot].to_i, sums[:sld].to_i, sums[:net].to_i, '', '', sums[:ote], '']
  end

  def to_statement_line
    "%10s %10s %10s %+50s %6d %6d %6d %12s %12.7f %12.2f %3s\n" % [posted_on, traded_on, account_code, claim_name, bot.to_i, sld.to_i, net.to_i, price_traded, mark, ote, currency_code]
  end
end
