class CreateDealingVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :dealing_venues do |t|
      t.integer :entity_id, null: false
      t.integer :dealing_venue_type_id, null: false
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :dealing_venues, :code, unique: true, name: 'dealing_venue_code_uq'
    add_index :dealing_venues, :name, unique: true, name: 'dealing_venue_name_uq'
    add_foreign_key :dealing_venues, :entities, name: 'dealing_venue_entity_type_fk'
    add_foreign_key :dealing_venues, :dealing_venue_types, name: 'dealing_venue_dealing_venue_type_fk'
  end
end
