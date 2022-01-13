class CreateStatementDealLegFills < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_deal_leg_fills do |t|
      t.integer :account_id
      t.string :account_code
      t.string :claim_code
      t.string :claim_name
      t.date :stated_on
      t.date :posted_on
      t.date :traded_on
      t.decimal :bot
      t.decimal :sld
      t.decimal :net
      t.decimal :price
      t.string :price_traded

      t.timestamps null: false
    end
    add_foreign_key :statement_deal_leg_fills, :accounts, name: :statement_deal_leg_fill_account

    add_index :statement_deal_leg_fills, :stated_on
    add_index :statement_deal_leg_fills, :posted_on
    add_index :statement_deal_leg_fills, [:account_code, :claim_code, :posted_on, :traded_on, :price], unique: true, name: :statement_deal_leg_fill_uq
  end
end
