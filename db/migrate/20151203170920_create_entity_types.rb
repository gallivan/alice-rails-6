class CreateEntityTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :entity_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :entity_types, :code, unique: true, name: 'entity_type_code_uq'
    add_index :entity_types, :name, unique: true, name: 'entity_type_name_uq'
  end
end
