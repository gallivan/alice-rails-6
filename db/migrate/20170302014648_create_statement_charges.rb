class CreateStatementCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_charges do |t|
      t.date :posted_on
      t.date :stated_on
      t.integer :account_id
      t.string :account_code
      t.string :charge_code
      t.string :journal_code
      t.string :currency_code
      t.decimal :amount
      t.string :memo

      t.timestamps null: false
    end
  end
end
