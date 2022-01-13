# == Schema Information
#
# Table name: statement_charges
#
#  id            :integer          not null, primary key
#  posted_on     :date
#  stated_on     :date
#  account_id    :integer
#  account_code  :string
#  charge_code   :string
#  journal_code  :string
#  currency_code :string
#  amount        :decimal(, )
#  memo          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class StatementCharge < ApplicationRecord
  validates :posted_on, presence: true
  validates :stated_on, presence: true
  validates :account_id, presence: true
  validates :account_code, presence: true
  validates :charge_code, presence: true
  validates :journal_code, presence: true
  validates :currency_code, presence: true
  validates :amount, presence: true
  validates :memo, presence: true

  belongs_to :account

  scope :stated_on, -> (date) { where(stated_on: date) }
  scope :posted_on, -> (date) { where(posted_on: date) }

  def to_statement_line_header
    "%10s %10s %+107s %12s %3s\n" % %W(Posted Account Memo Amount CCY)
  end

  def to_statement_line
    "%10s %10s %+107s %12.2f %3s\n" % [posted_on, account_code, memo, amount, currency_code]
  end
end
