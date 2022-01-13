class CreateEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :entities do |t|
      t.integer :entity_type_id, null: false
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_foreign_key :entities, :entity_types, name: 'entity_entity_type_fk'
    add_index :entities, :code, unique: true, name: 'entity_code_uq'
    add_index :entities, :name, unique: true, name: 'entity_name_uq'
  end
end
