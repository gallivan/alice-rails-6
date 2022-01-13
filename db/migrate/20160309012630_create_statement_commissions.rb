class CreateStatementCommissions < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_commissions do |t|
      t.date :posted_on
      t.date :stated_on
      t.integer :account_id
      t.string :account_code
      t.string :commission_code
      t.string :journal_code
      t.string :currency_code
      t.decimal :amount
      t.string :memo

      t.timestamps null: false
    end
    add_foreign_key :statement_commissions, :accounts

    add_index :statement_commissions, :stated_on
    add_index :statement_commissions, :posted_on
    add_index :statement_commissions, :account_id
  end
end
