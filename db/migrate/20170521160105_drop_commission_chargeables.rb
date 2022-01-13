class DropCommissionChargeables < ActiveRecord::Migration[5.2]
  def up
    execute(%q(DROP TABLE IF EXISTS commission_chargeables;))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
