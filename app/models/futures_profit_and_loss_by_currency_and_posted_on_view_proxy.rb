# == Schema Information
#
# Table name: futures_profit_and_loss_by_currency_and_posted_on_view
#
#  currency_id :integer
#  posted_on   :date
#  pnl_futures :decimal(, )
#  kind        :string
#

class FuturesProfitAndLossByCurrencyAndPostedOnViewProxy < ApplicationRecord
  self.table_name = 'futures_profit_and_loss_by_currency_and_posted_on_view'

  belongs_to :currency
end
