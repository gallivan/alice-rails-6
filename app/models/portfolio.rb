# == Schema Information
#
# Table name: portfolios
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  note       :string
#  posted_on  :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Portfolio < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true
  validates :posted_on, presence: true

  has_one :account_portfolio
  has_one :account, through: :account_portfolio

  has_many :portfolio_positions
  has_many :positions, through: :portfolio_positions

  has_many :margins

  def self.build(account, posted_on)
    if account.reg?
      positions = account.positions.open.cme_core_marginable
    else
      positions = []
      Account.reg.active.each{|a| positions << a.positions.open.cme_core_marginable}
      positions.flatten!
    end

    portfolio = Portfolio.create! do |p|
      p.code = "#{account.code} #{posted_on.strftime("%Y-%m-%d")}"
      p.name = "#{account.name} #{posted_on.strftime("%Y-%m-%d")}"
      p.posted_on = posted_on
    end

    AccountPortfolio.build_set(account, portfolio)
    PortfolioPosition.build_set(portfolio, positions)

    portfolio
  end
end
