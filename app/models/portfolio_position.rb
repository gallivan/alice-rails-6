# == Schema Information
#
# Table name: portfolio_positions
#
#  id           :integer          not null, primary key
#  portfolio_id :integer          not null
#  position_id  :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PortfolioPosition < ApplicationRecord
  validates :portfolio_id, presence: true
  validates :position_id, presence: true

  belongs_to :portfolio
  belongs_to :position

  def self.build_set(portfolio, positions)
    positions.each do |position|
      PortfolioPosition.create! do |x|
        x.portfolio = portfolio
        x.position = position
      end
    end
  end
end
