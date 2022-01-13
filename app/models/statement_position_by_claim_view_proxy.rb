# == Schema Information
#
# Table name: statement_position_by_claim_view
#
#  currency_id :integer
#  claim_id    :integer
#  stated_on   :date
#  bot         :decimal(, )
#  sld         :decimal(, )
#  net         :decimal(, )
#  avg_bot_px  :decimal(, )
#  avg_sld_px  :decimal(, )
#  price       :decimal(, )
#  mark        :decimal(, )
#  ote         :decimal(, )
#

class StatementPositionByClaimViewProxy < ApplicationRecord
  self.table_name = 'statement_position_by_claim_view'

  belongs_to :currency
  belongs_to :claim
end
