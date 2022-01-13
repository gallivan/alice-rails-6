class CreateFees < ActiveRecord::Migration[5.2]
  def change
    create_table :fees do |t|
      t.integer :account_id, null: false
      t.integer :fee_chargeable_id
      t.integer :journal_entry_id
      t.decimal :amount, null: false
      t.integer :currency_id, null: false
      t.date :posted_on, null: false
      t.string :memo

      t.timestamps null: false
    end
    add_foreign_key :fees, :accounts, name: 'fee_account_fk'
    add_foreign_key :fees, :fee_chargeables, name: 'fee_fee_schedule_fk'
    add_foreign_key :fees, :journal_entries, name: 'fee_journal_entry_fk'
  end
end
