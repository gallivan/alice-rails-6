json.array!(@claim_sub_types) do |claim_sub_type|
  json.extract! claim_sub_type, :id, :code, :name
  json.url claim_sub_type_url(claim_sub_type, format: :json)
end
