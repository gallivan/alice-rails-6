class CreateJournalEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :journal_entries do |t|
      t.integer :journal_id, null: false
      t.integer :journal_entry_type_id, null: false
      t.integer :account_id, null: false
      t.integer :currency_id, null: false
      t.date :posted_on, null: false
      t.date :as_of_on, null: false
      t.decimal :amount, null: false
      t.string :memo, null: false

      t.timestamps null: false
    end
    add_foreign_key :journal_entries, :journals, name: 'journal_entry_journal_fk'
    add_foreign_key :journal_entries, :accounts, name: 'journal_entry_account_fk'
    add_foreign_key :journal_entries, :journal_entry_types, name: 'journal_entry_journal_entry_type_fk'
  end
end
