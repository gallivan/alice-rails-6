json.array!(@system_types) do |system_type|
  json.extract! system_type, :id, :code, :name
  json.url system_type_url(system_type, format: :json)
end
