json.array!(@statement_positions) do |statement_position|
  json.extract! statement_position, :id, :account_id, :account_code, :claim_code, :stated_on, :posted_on, :traded_on, :bot, :sld, :net, :price, :mark, :ote, :currency_code, :position_status_code
  json.url statement_position_url(statement_position, format: :json)
end
