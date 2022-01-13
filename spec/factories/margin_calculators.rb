FactoryBot.define do
  factory :margin_calculator do
    code { Faker::Lorem.characters(4).upcase }
    name { Faker::Lorem.words(4, true).join ' '}
    note { Faker::Lorem.words(4, true).join ' '}
  end

end
