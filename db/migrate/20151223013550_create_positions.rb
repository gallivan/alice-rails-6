class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.integer :account_id, null: false
      t.integer :claim_id, null: false
      t.date :posted_on, null: false
      t.date :traded_on, null: false
      t.decimal :price, null: false
      t.string :price_traded, null: false
      t.decimal :bot, null: false, default: 0
      t.decimal :sld, null: false, default: 0
      t.decimal :bot_off, null: false, default: 0
      t.decimal :sld_off, null: false, default: 0
      t.decimal :net, null: false, default: 0
      t.decimal :mark
      t.decimal :ote
      t.integer :currency_id, null: false
      t.integer :position_status_id, null: false

      t.timestamps null: false
    end
    add_index :positions, [:account_id, :claim_id, :posted_on, :traded_on, :price], name: 'positions_uq'

    add_foreign_key :positions, :claims, name: 'positions_claims_fk'
    add_foreign_key :positions, :accounts, name: 'positions_accounts_fk'
    add_foreign_key :positions, :currencies, name: 'positions_currencies_fk'
    add_foreign_key :positions, :position_statuses, name: 'positions_position_status_fk'
  end
end

# rails generate scaffold Position \
# account_id:integer \
# claim_id:integer \
# currency_id:integer \
# position_status_id:integer \
# posted_on:date \
# traded_on:date \
# price:decimal \
# price_traded:string \
# bot:decimal \
# sld:decimal \
# bot_off:decimal \
# sld_off:decimal \
# net:decimal \
# mark:decimal \
# ote:decimal