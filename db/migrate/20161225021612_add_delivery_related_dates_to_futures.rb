class AddDeliveryRelatedDatesToFutures < ActiveRecord::Migration[5.2]
  def change
    add_column :futures, :first_holding_on, :date
    add_column :futures, :first_intent_on, :date
    add_column :futures, :first_delivery_on, :date
    add_column :futures, :last_trade_on, :date
    add_column :futures, :last_intent_on, :date
    add_column :futures, :last_delivery_on, :date
  end
end
