json.array!(@user_duties) do |user_duty|
  json.extract! user_duty, :id, :user_id, :duty_id
  json.url user_duty_url(user_duty, format: :json)
end
