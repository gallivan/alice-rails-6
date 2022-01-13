json.array!(@systems) do |system|
  json.extract! system, :id, :entity_id, :system_type_id, :code, :name
  json.url system_url(system, format: :json)
end
