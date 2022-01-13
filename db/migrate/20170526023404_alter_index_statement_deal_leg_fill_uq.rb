class AlterIndexStatementDealLegFillUq < ActiveRecord::Migration[5.2]
  def up
    remove_index :statement_deal_leg_fills, name: :statement_deal_leg_fill_uq
    add_index :statement_deal_leg_fills, [:account_code, :claim_code, :posted_on, :traded_on, :price, :price_traded], unique: true, name: :statement_deal_leg_fill_uq
  end

  def down
    remove_index :statement_deal_leg_fills, name: :statement_deal_leg_fill_uq
    add_index :statement_deal_leg_fills, [:account_code, :claim_code, :posted_on, :traded_on, :price], unique: true, name: :statement_deal_leg_fill_uq
  end
end
