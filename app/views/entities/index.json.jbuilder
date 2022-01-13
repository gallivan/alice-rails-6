json.array!(@entities) do |entity|
  json.extract! entity, :id, :entity_type_id, :code, :name
  json.url entity_url(entity, format: :json)
end
