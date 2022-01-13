class CreateSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :systems do |t|
      t.integer :entity_id, null: false
      t.integer :system_type_id, null: false
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :systems, :code, unique: true, name: 'system_code_uq'
    add_index :systems, :name, unique: true, name: 'system_name_uq'
    add_foreign_key :systems, :entities, name: 'system_entity_fk'
    add_foreign_key :systems, :system_types, name: 'system_system_type_fk'
  end
end
