class CreateAccountTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :account_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :account_types, :code, unique: true, name: 'account_type_code_uq'
    add_index :account_types, :name, unique: true, name: 'account_type_name_uq'
  end
end
