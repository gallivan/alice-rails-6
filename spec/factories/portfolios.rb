FactoryBot.define do

  factory :portfolio do
    portfolio_type
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
    note { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
