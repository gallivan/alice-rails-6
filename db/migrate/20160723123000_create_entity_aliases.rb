class CreateEntityAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :entity_aliases do |t|
      t.integer :system_id
      t.integer :entity_id
      t.string :code

      t.timestamps null: false
    end
    add_index :entity_aliases, [:system_id, :entity_id], unique: true

    add_foreign_key :entity_aliases, :systems, name: 'entity_alias_system_fk'
    add_foreign_key :entity_aliases, :entities, name: 'entity_alias_entity_fk'
  end
end
