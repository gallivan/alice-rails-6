class CreateMoneyLines < ActiveRecord::Migration[5.2]
  def change
    create_table :money_lines do |t|
      t.integer :account_id, null: false
      t.integer :currency_held_id, null: false
      t.integer :currency_base_id, null: false
      t.integer :currency_mark_id, null: false
      t.date :posted_on, null: false
      t.decimal :beginning_balance, default: 0.0, null: false
      t.decimal :cash, default: 0.0, null: false
      t.decimal :fees, default: 0.0, null: false
      t.decimal :commissions, default: 0.0, null: false
      t.decimal :pnl_futures, default: 0.0, null: false
      t.decimal :pnl_options, default: 0.0, null: false
      t.decimal :adjustments, default: 0.0, null: false
      t.decimal :rebates, default: 0.0, null: false
      t.decimal :charges, default: 0.0, null: false
      t.decimal :ledger_balance, default: 0.0, null: false
      t.decimal :open_trade_equity, default: 0.0, null: false
      t.decimal :cash_account_balance, default: 0.0, null: false
      t.decimal :margin, default: 0.0, null: false
      t.decimal :long_option_value, default: 0.0, null: false
      t.decimal :short_option_value, default: 0.0, null: false
      t.decimal :net_option_value, default: 0.0, null: false
      t.decimal :net_liquidating_balance, default: 0.0, null: false

      t.timestamps null: false
    end
    add_index :money_lines, [:account_id, :currency_held_id, :currency_base_id, :posted_on], unique: true, name: :money_lines_uq

    add_foreign_key :money_lines, :currencies, column: :currency_held_id, name: :money_line_ccy_held_fk
    add_foreign_key :money_lines, :currencies, column: :currency_base_id, name: :money_line_ccy_base_fk
    add_foreign_key :money_lines, :currency_marks, column: :currency_mark_id, name: :money_line_currency_mark_fk
  end
end

#rails generate scaffold MoneyLine account_id:integer currency_held_id:integer currency_base_id:integer currency_mark_id:integer posted_on:date beginning_balance:decimal cash:decimal fees:decimal commissions:decimal pnl_futures:decimal pnl_options:decimal adjustments:decimal rebates:decimal charges:decimal ledger_balance:decimal open_trade_equity:decimal cash_account_balance:decimal margin:decimal long_option_value:decimal short_option_value:decimal net_option_value:decimal net_liquidating_balance:decimal --skip