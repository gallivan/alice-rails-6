class AddCurrencyMarkToStatementMoneyLine < ActiveRecord::Migration[5.2]
  def change
    add_column :statement_money_lines, :currency_mark, :decimal
  end
end
