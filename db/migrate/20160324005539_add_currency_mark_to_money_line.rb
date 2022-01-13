class AddCurrencyMarkToMoneyLine < ActiveRecord::Migration[5.2]
  def change
    add_column :money_lines, :currency_mark, :decimal
  end
end
