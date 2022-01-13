class ChangeBotAndSldPriceTradedTypes < ActiveRecord::Migration[5.2]
  def up
    change_column :statement_position_nettings, :bot_price_traded, :string
    change_column :statement_position_nettings, :sld_price_traded, :string
  end

  def down
    remove_column :statement_position_nettings, :bot_price_traded
    remove_column :statement_position_nettings, :sld_price_traded

    add_column :statement_position_nettings, :bot_price_traded, :decimal
    add_column :statement_position_nettings, :sld_price_traded, :decimal
  end
end
