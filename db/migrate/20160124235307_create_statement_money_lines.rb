class CreateStatementMoneyLines < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_money_lines do |t|
      t.date :stated_on
      t.date :posted_on
      t.integer :account_id
      t.string :account_code
      t.string :held_currency_code
      t.string :base_currency_code
      t.decimal :beginning_balance
      t.decimal :fees
      t.decimal :commissions
      t.decimal :pnl_futures
      t.decimal :ledger_balance
      t.decimal :open_trade_equity
      t.decimal :cash_account_balance
      t.decimal :net_liquidating_balance

      t.timestamps null: false
    end
    add_foreign_key :statement_money_lines, :accounts, name: :statement_money_line_account_fk

    add_index :statement_money_lines, [:account_id, :stated_on, :held_currency_code, :base_currency_code], unique: true, name: :statement_money_line_uq
  end
end
