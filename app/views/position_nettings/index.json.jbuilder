json.array!(@position_nettings) do |position_netting|
  json.extract! position_netting, :id, :account_id, :currency_id, :claim_id, :position_netting_type_id, :bot_position_id, :sld_position_id, :posted_on, :done, :bot_price, :sld_price, :bot_price_traded, :sld_price_traded, :pnl
  json.url position_netting_url(position_netting, format: :json)
end
