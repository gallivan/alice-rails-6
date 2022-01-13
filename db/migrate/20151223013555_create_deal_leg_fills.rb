class CreateDealLegFills < ActiveRecord::Migration[5.2]
  def change
    create_table :deal_leg_fills do |t|
      t.integer :deal_leg_id #, null: false ##################################### TEMPORARILY RELAX CONSTRAINT
      t.integer :system_id, null: false
      t.integer :dealing_venue_id, null: false
      t.string :dealing_venue_done_id, null: false
      t.integer :account_id
      t.integer :claim_id
      t.decimal :done, null: false
      t.decimal :price, null: false
      t.string :price_traded, null: false
      t.date :posted_on, null: false
      t.date :traded_on, null: false
      t.timestamp :traded_at, null: false
      t.integer :position_id
      t.integer :booker_report_id
      t.string :kind, null: false

      t.timestamps null: false
    end
    add_index :deal_leg_fills, [:dealing_venue_id, :dealing_venue_done_id, :claim_id, :account_id], unique: true, name: 'deal_leg_fills_uq'

    add_foreign_key :deal_leg_fills, :deal_legs, name: 'fill_to_leg_fk'
    add_foreign_key :deal_leg_fills, :dealing_venues, name: 'fill_to_dealing_venue_fk'

    add_foreign_key :deal_leg_fills, :claims, name: 'fill_claim_fk'
    add_foreign_key :deal_leg_fills, :systems, name: 'fill_system_fk'
    add_foreign_key :deal_leg_fills, :accounts, name: 'fill_account_fk'
    add_foreign_key :deal_leg_fills, :positions, name: 'fill_position_fk'
    add_foreign_key :deal_leg_fills, :booker_reports, name: 'fill_booker_report_fk'
  end
end
