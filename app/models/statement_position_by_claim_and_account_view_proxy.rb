# == Schema Information
#
# Table name: statement_position_by_claim_and_account_view
#
#  currency_id :integer
#  account_id  :integer
#  claim_id    :integer
#  stated_on   :date
#  bot         :decimal(, )
#  sld         :decimal(, )
#  net         :decimal(, )
#  price       :decimal(, )
#  mark        :decimal(, )
#  ote         :decimal(, )
#

class StatementPositionByClaimAndAccountViewProxy < ApplicationRecord
  self.table_name = 'statement_position_by_claim_and_account_view'

  belongs_to :currency
  belongs_to :account
  belongs_to :claim
end
