json.array!(@format_types) do |format_type|
  json.extract! format_type, :id, :code, :name
  json.url format_type_url(format_type, format: :json)
end
