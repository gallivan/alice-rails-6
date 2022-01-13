class CreateDealingVenueAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :dealing_venue_aliases do |t|
      t.integer :dealing_venue_id, null: false
      t.integer :system_id, null: false
      t.string :code, null: false

      t.timestamps null: false
    end
    add_index :dealing_venue_aliases, [:dealing_venue_id, :system_id, :code], name: 'dealing_venue_aliases_uq'
    add_foreign_key :dealing_venue_aliases, :dealing_venues, name: 'dealing_venue_aliase_dealing_venue_fx'
    add_foreign_key :dealing_venue_aliases, :systems, name: 'dealing_venue_aliases_system_fx'
  end
end
