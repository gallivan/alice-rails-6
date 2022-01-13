class CreateLedgerEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_entries do |t|
      t.integer :ledger_id, null: false
      t.integer :ledger_entry_type_id, null: false
      t.integer :account_id, null: false
      t.integer :currency_id, null: false
      t.date :posted_on, null: false
      t.date :as_of_on, null: false
      t.decimal :amount, null: false
      t.string :memo, null: false

      t.timestamps null: false
    end
    add_index :ledger_entries, [:posted_on, :ledger_id, :ledger_entry_type_id, :currency_id], unique: true, name: :ledger_entries_uq
    add_foreign_key :ledger_entries, :ledgers, name: 'ledger_entry_ledger_fk'
    add_foreign_key :ledger_entries, :accounts, name: 'ledger_entry_account_fk'
    add_foreign_key :ledger_entries, :ledger_entry_types, name: 'ledger_entry_ledger_entry_type_fk'
    add_foreign_key :ledger_entries, :currencies, name: 'ledger_entry_currency_fk'
  end
end
