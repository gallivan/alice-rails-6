json.array!(@picker_reports) do |picker_report|
  json.extract! picker_report, :id, :posted_on, :kind, :fate, :data, :goof_error, :goof_trace
  json.url picker_report_url(picker_report, format: :json)
end
