json.array!(@claim_marks) do |claim_mark|
  json.extract! claim_mark, :id, :system_id, :claim_id, :posted_on, :mark
  json.url claim_mark_url(claim_mark, format: :json)
end
