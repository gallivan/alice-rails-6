class DropFees < ActiveRecord::Migration[5.2]
  def up
    execute(%q(DROP TABLE IF EXISTS fees;))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
