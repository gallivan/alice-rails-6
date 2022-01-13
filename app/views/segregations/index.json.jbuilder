json.array!(@segregations) do |segregation|
  json.extract! segregation, :id, :code, :name, :note
  json.url segregation_url(segregation, format: :json)
end
