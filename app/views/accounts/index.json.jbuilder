json.array!(@accounts) do |account|
  json.extract! account, :id, :account_type_id, :entity_id, :code, :name, :active
  json.url account_url(account, format: :json)
end
