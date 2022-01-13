json.array!(@claim_sets) do |claim_set|
  json.extract! claim_set, :id, :code, :name
  json.url claim_set_url(claim_set, format: :json)
end
