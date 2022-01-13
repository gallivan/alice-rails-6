class CreateAccountAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :account_aliases do |t|
      t.integer :system_id, null: false
      t.integer :account_id, null: false
      t.string :code, null: false

      t.timestamps null: false
    end
    add_index :account_aliases, :system_id
    add_index :account_aliases, :account_id
    add_index :account_aliases, [:system_id, :account_id], unique: true, name: 'account_alias_uq'
    add_foreign_key :account_aliases, :systems
    add_foreign_key :account_aliases, :accounts
  end
end
