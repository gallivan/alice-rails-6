class DropFeeChargeableTypes < ActiveRecord::Migration[5.2]
  def up
    execute(%q(DROP TABLE IF EXISTS fee_chargeable_types;))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
