json.array!(@claims) do |claim|
  json.extract! claim, :id, :claim_set_id, :claim_type_id, :entity_id, :claimable_id, :claimable_type, :code, :name, :size, :point_value, :point_currency_id
  json.url claim_url(claim, format: :json)
end
