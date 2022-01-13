class CreateClearingVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :clearing_venues do |t|
      t.integer :entity_id, null: false
      t.integer :clearing_venue_type_id, null: false
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :clearing_venues, :code, unique: true, name: 'clearing_venue_code_uq'
    add_index :clearing_venues, :name, unique: true, name: 'clearing_venue_name_uq'
    add_foreign_key :clearing_venues, :entities, name: 'clearing_venue_entity_fk'
    add_foreign_key :clearing_venues, :clearing_venue_types, name: 'clearing_venue_clearing_venue_type_fk'
  end
end
