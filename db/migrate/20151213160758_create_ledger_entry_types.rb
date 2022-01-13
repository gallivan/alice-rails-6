class CreateLedgerEntryTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_entry_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :ledger_entry_types, :code, unique: true, name: 'ledger_entry_type_code_uq'
    add_index :ledger_entry_types, :name, unique: true, name: 'ledger_entry_type_name_uq'
  end
end
