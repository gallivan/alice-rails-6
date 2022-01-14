FactoryBot.define do
  factory :margin_request do
    margin {nil}
    margin_request_status
    error {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
