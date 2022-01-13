# == Schema Information
#
# Table name: open_trade_equity_by_currency_and_posted_on_view
#
#  currency_id       :integer
#  posted_on         :date
#  open_trade_equity :decimal(, )
#  kind              :string
#

class OpenTradeEquityByCurrencyAndPostedOnViewProxy < ApplicationRecord
  self.table_name = 'open_trade_equity_by_currency_and_posted_on_view'

  belongs_to :currency
end
