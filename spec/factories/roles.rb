FactoryBot.define do

  factory :role do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Company.name }
  end

end
