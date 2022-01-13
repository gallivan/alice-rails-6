json.array!(@duties) do |duty|
  json.extract! duty, :id, :code, :name
  json.url duty_url(duty, format: :json)
end
