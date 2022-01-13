class CreateLedgerTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :ledger_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :ledger_types, :code, unique: true, name: 'ledger_type_code_uq'
    add_index :ledger_types, :name, unique: true, name: 'ledger_type_name_uq'
  end
end
