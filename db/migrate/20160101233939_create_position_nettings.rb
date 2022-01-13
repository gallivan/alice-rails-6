class CreatePositionNettings < ActiveRecord::Migration[5.2]
  def change
    create_table :position_nettings do |t|
      t.integer :account_id, null: false
      t.integer :currency_id, null: false
      t.integer :claim_id, null: false
      t.integer :position_netting_type_id, null: false
      t.integer :bot_position_id, null: false
      t.integer :sld_position_id, null: false
      t.date :posted_on, null: false
      t.decimal :done, null: false
      t.decimal :bot_price, null: false
      t.decimal :sld_price, null: false
      t.string :bot_price_traded, null: false
      t.string :sld_price_traded, null: false
      t.decimal :pnl, null: false

      t.timestamps null: false
    end
    add_foreign_key :position_nettings, :claims, name: :position_netting_claim_fk
    add_foreign_key :position_nettings, :accounts, name: :position_netting_account_fk
    add_foreign_key :position_nettings, :currencies, name: :position_netting_currency_fk
    add_foreign_key :position_nettings, :position_netting_types, name: :position_netting_type_fk

    add_foreign_key :position_nettings, :positions, column: :bot_position_id, name: :bot_position_fk
    add_foreign_key :position_nettings, :positions, column: :sld_position_id, name: :sld_position_fk
  end
end

# rails generate scaffold PositionNetting \
# account_id:integer \
# currency_id:integer \
# claim_id:integer \
# position_netting_type_id:integer \
# bot_position_id:integer \
# sld_position_id:integer \
# posted_on:date \
# done:decimal \
# bot_price:decimal \
# sld_price:decimal \
# bot_price_traded:string \
# sld_price_traded:string \
# pnl:decimal