class DropFeesByExchangeAndPostedOnView < ActiveRecord::Migration[5.2]
  def up
    sql ='DROP VIEW IF EXISTS fees_by_exchange_and_posted_on_view;'
    execute sql
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
