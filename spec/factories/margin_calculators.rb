FactoryBot.define do
  factory :margin_calculator do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
    note { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
