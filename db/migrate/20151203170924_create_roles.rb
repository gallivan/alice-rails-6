class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :roles, :code, unique: true, name: 'role_code_uq'
    add_index :roles, :name, unique: true, name: 'role_name_uq'
  end
end
