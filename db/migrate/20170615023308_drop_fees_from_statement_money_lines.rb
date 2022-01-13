class DropFeesFromStatementMoneyLines < ActiveRecord::Migration[5.2]
  def up
    remove_column :statement_money_lines, :fees
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
