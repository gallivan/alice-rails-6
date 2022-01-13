class CreateJournalEntryTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :journal_entry_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :journal_entry_types, :code, unique: true, name: 'journal_entry_type_code_uq'
    add_index :journal_entry_types, :name, unique: true, name: 'journal_entry_type_name_uq'
  end
end
