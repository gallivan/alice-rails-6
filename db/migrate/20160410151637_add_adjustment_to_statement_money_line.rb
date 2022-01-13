class AddAdjustmentToStatementMoneyLine < ActiveRecord::Migration[5.2]
  def change
    add_column :statement_money_lines, :adjustments, :decimal
  end
end
