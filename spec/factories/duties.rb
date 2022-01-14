FactoryBot.define do

  factory :duty do
    code { Faker::Lorem.characters(number: 3).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' ' }
  end

end
