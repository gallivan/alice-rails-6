class CreateDealingVenueTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :dealing_venue_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :dealing_venue_types, :code, unique: true, name: 'dealing_venue_type_code_uq'
    add_index :dealing_venue_types, :name, unique: true, name: 'dealing_venue_type_name_uq'
  end
end
