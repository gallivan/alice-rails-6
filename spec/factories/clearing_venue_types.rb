FactoryBot.define do
  factory :clearing_venue_type do
    code { Faker::Lorem.characters(3).upcase }
    name { Faker::Lorem.words(4, true).join ' '}
  end
end
