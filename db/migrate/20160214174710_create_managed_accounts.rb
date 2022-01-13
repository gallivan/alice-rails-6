class CreateManagedAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :managed_accounts do |t|
      t.integer :user_id, null: false
      t.integer :account_id, null: false

      t.timestamps null: false
    end
    add_index :managed_accounts, [:user_id, :account_id], unique: true
    add_foreign_key :managed_accounts, :users, name: 'managed_account_user_fk'
    add_foreign_key :managed_accounts, :accounts, name: 'managed_account_account_fk'
  end
end
