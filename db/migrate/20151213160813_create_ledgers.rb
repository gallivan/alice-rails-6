class CreateLedgers < ActiveRecord::Migration[5.2]
  def change
    create_table :ledgers do |t|
      t.integer :ledger_type_id, null: false
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :ledgers, :code, unique: true, name: 'ledger_code_uq'
    add_index :ledgers, :name, unique: true, name: 'ledger_name_uq'
    add_foreign_key :ledgers, :ledger_types, name: 'ledger_ledger_type_fk'
  end
end
