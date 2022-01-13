json.array!(@statement_position_nettings) do |statement_position_netting|
  json.extract! statement_position_netting, :id, :stated_on, :posted_on, :account_id, :account_code, :claim_code, :netting_code, :bot_price_traded, :sld_price_traded, :done, :pnl, :currency_code
  json.url statement_position_netting_url(statement_position_netting, format: :json)
end
