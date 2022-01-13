FactoryBot.define do
  factory :margin_request do
    margin {nil}
    margin_request_status
    error {Faker::Lorem.words(4, true).join ' '}
  end

end
