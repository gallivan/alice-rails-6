# == Schema Information
#
# Table name: margins
#
#  id                   :integer          not null, primary key
#  portfolio_id         :integer          not null
#  margin_calculator_id :integer          not null
#  margin_status_id     :integer          not null
#  currency_id          :integer          not null
#  remote_portfolio_id  :string
#  remote_margin_id     :string
#  initial              :decimal(12, 2)
#  maintenance          :decimal(12, 2)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  posted_on            :date
#

class Margin < ApplicationRecord
  validates :margin_calculator_id, presence: true
  validates :margin_status, presence: true
  validates :currency_id, presence: true
  # validates :posted_on, presence: true

  belongs_to :portfolio
  # belongs_to :margin_type
  belongs_to :margin_status
  belongs_to :margin_calculator
  belongs_to :currency

  has_many :margin_requests

  def self.build(portfolio, posted_on)
    Margin.create! do |m|
      m.portfolio = portfolio
      m.margin_calculator = MarginCalculator.first
      m.margin_status = MarginStatus.find_by_code 'OPEN'
      m.posted_on = posted_on
      m.currency = Currency.usd
      m.initial = 0
      m.maintenance = 0
    end
  end

end
