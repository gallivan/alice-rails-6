class CorrectStatementMoneyLine < ActiveRecord::Migration[5.2]
  def up
    rename_column :statement_money_lines, :held_currency_code, :currency_code
    rename_column :statement_money_lines, :base_currency_code, :kind

    execute <<-SQL
      update statement_money_lines set kind = 'HELD';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
