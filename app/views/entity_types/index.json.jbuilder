json.array!(@entity_types) do |entity_type|
  json.extract! entity_type, :id, :code, :name
  json.url entity_type_url(entity_type, format: :json)
end
