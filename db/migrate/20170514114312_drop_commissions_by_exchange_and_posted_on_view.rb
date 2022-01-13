class DropCommissionsByExchangeAndPostedOnView < ActiveRecord::Migration[5.2]
  def up
    sql ='DROP VIEW IF EXISTS commissions_by_exchange_and_posted_on_view;'
    execute sql
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
