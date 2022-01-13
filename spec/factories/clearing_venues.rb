FactoryBot.define do

  factory :clearing_venue do
    code { Faker::Lorem.characters(3).upcase }
    name { Faker::Company.name }
  end

end
