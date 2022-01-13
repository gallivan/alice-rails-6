json.array!(@packer_reports) do |packer_report|
  json.extract! packer_report, :id, :posted_on, :kind, :fate, :data, :goof_error, :goof_trace
  json.url packer_report_url(packer_report, format: :json)
end
