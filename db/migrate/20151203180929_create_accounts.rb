class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :entity_id, null: false
      t.integer :account_type_id, null: false
      t.string :code, unique: true, null: false
      t.string :name, unique: true, null: false
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
    add_index :accounts, :code, unique: true, name: 'account_code_uq'
    add_index :accounts, :name, unique: true, name: 'account_name_uq'
    add_foreign_key :accounts, :entities, name: 'account_entity_fk'
    add_foreign_key :accounts, :account_types, name: 'account_account_type_fk'
  end
end
