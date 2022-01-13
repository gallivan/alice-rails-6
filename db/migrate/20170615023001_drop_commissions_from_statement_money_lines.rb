class DropCommissionsFromStatementMoneyLines < ActiveRecord::Migration[5.2]
  def up
    remove_column :statement_money_lines, :commissions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
