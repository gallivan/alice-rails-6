class AddChargesToStatementMoneyLine < ActiveRecord::Migration[5.2]
  def change
    add_column :statement_money_lines, :charges, :decimal
  end
end
