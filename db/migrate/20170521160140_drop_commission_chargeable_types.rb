class DropCommissionChargeableTypes < ActiveRecord::Migration[5.2]
  def up
    execute(%q(DROP TABLE IF EXISTS commission_chargeable_types;))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
