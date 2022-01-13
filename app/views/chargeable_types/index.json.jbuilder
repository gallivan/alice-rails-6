json.array!(@chargeable_types) do |chargeable_type|
  json.extract! chargeable_type, :id, :code, :name
  json.url chargeable_type_url(chargeable_type, format: :json)
end
