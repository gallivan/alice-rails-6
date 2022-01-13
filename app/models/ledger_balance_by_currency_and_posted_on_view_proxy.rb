# == Schema Information
#
# Table name: ledger_balance_by_currency_and_posted_on_view
#
#  currency_id    :integer
#  posted_on      :date
#  ledger_balance :decimal(, )
#  kind           :string
#

class LedgerBalanceByCurrencyAndPostedOnViewProxy < ApplicationRecord
  self.table_name = 'ledger_balance_by_currency_and_posted_on_view'

  belongs_to :currency
end
