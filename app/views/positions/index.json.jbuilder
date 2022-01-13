json.array!(@positions) do |position|
  json.extract! position, :id, :account_id, :claim_id, :currency_id, :position_status_id, :posted_on, :traded_on, :price, :price_traded, :bot, :sld, :bot_off, :sld_off, :net, :mark, :ote
  json.url position_url(position, format: :json)
end
