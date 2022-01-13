class CreateSystemTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :system_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :system_types, :code, unique: true, name: 'system_type_code_uq'
    add_index :system_types, :name, unique: true, name: 'system_type_name_uq'
  end
end
