json.array!(@reports) do |report|
  json.extract! report, :id, :report_type_id, :format_type_id, :memo, :location
  json.url report_url(report, format: :json)
end
