FactoryBot.define do

  factory :portfolio do
    portfolio_type
    code { Faker::Lorem.characters(4).upcase }
    name { Faker::Lorem.words(4, true).join ' '}
    note { Faker::Lorem.words(4, true).join ' '}
  end

end
