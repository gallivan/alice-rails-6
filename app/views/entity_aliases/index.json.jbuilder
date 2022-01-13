json.array!(@entity_aliases) do |entity_alias|
  json.extract! entity_alias, :id, :system_id, :entity_id, :code
  json.url entity_alias_url(entity_alias, format: :json)
end
