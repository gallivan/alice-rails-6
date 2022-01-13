# == Schema Information
#
# Table name: account_portfolios
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  portfolio_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AccountPortfolio < ApplicationRecord
  validates :account_id, presence: true
  validates :portfolio_id, presence: true

  belongs_to :account
  belongs_to :portfolio

  def self.build_set(account, portfolio)
    AccountPortfolio.create! do |x|
      x.account_id = account.id
      x.portfolio_id = portfolio.id
    end
  end
end
