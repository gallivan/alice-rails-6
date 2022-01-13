json.array!(@booker_reports) do |booker_report|
  json.extract! booker_report, :id, :posted_on, :kind, :fate, :data, :goof_error, :goof_trace
  json.url booker_report_url(booker_report, format: :json)
end
