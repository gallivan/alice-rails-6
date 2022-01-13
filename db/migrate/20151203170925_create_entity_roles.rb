class CreateEntityRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :entity_roles do |t|
      t.integer :entity_id, null: false
      t.integer :role_id, null: false

      t.timestamps null: false
    end
    add_index :entity_roles, [:entity_id, :role_id], unique: true, name: 'entity_role_uq'
    add_foreign_key :entity_roles, :entities, name: 'entity_role_entity_fk'
    add_foreign_key :entity_roles, :roles, name: 'entity_role_role_fk'
  end
end
