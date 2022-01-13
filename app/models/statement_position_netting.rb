# == Schema Information
#
# Table name: statement_position_nettings
#
#  id               :integer          not null, primary key
#  stated_on        :date
#  posted_on        :date
#  account_id       :integer
#  account_code     :string
#  claim_code       :string
#  claim_name       :string
#  netting_code     :string
#  bot_price_traded :string
#  sld_price_traded :string
#  done             :decimal(, )
#  pnl              :decimal(, )
#  currency_code    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class StatementPositionNetting < ApplicationRecord
  validates :account_id, presence: true
  validates :stated_on, presence: true
  validates :posted_on, presence: true
  validates :account_code, presence: true
  validates :claim_code, presence: true
  validates :netting_code, presence: true
  validates :done, presence: true
  validates :bot_price_traded, presence: true
  validates :sld_price_traded, presence: true
  validates :pnl, presence: true
  validates :currency_code, presence: true

  belongs_to :account

  scope :stated_on, -> (date) { where(stated_on: date) }
  scope :traded_on, -> (date) { where(traded_on: date) }
  scope :posted_on, -> (date) { where(posted_on: date) }

  def to_statement_line_header
    "%10s %10s %+65s %3s %12s %12s %10s %14s %3s\n" % %W(Posted Account Claim How Bot Sld Done PnL CCY)
  end

  def to_statement_line_summary(sums)
    "%10s %10s %+65s %3s %12s %12s %10s %14.2f %3s\n" % ['', '', '', '', '', '', sums[:done].to_i, sums[:pnl], '']
  end

  def to_statement_line
    "%10s %10s %+65s %3s %12s %12s %10s %14.2f %3s\n" % [posted_on, account_code, claim_name, netting_code, bot_price_traded, sld_price_traded, done.to_i, pnl, currency_code]
  end
end
