# == Schema Information
#
# Table name: charges_by_exchange_and_posted_on_view
#
#  posted_on          :date
#  chargeable_type_id :integer
#  currency_id        :integer
#  entity_id          :integer
#  amount             :decimal(, )
#

class ChargesByExchangeAndPostedOnProxy < ApplicationRecord
  self.table_name = 'charges_by_exchange_and_posted_on_view'

  belongs_to :entity
  belongs_to :currency
  belongs_to :chargeable_type
end
