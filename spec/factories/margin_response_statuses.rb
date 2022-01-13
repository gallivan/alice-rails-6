FactoryBot.define do

  factory :margin_response_status do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Lorem.words(4, true).join ' '}
  end

end
