json.array!(@statement_deal_leg_fills) do |statement_deal_leg_fill|
  json.extract! statement_deal_leg_fill, :id, :account_id, :account_code, :claim_code, :stated_on, :posted_on, :traded_on, :bot, :sld, :net, :price, :price_traded
  json.url statement_deal_leg_fill_url(statement_deal_leg_fill, format: :json)
end
