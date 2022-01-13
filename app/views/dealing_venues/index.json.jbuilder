json.array!(@dealing_venues) do |dealing_venue|
  json.extract! dealing_venue, :id, :entity_id, :dealing_venue_type_id, :code, :name
  json.url dealing_venue_url(dealing_venue, format: :json)
end
