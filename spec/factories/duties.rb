FactoryBot.define do

  factory :duty do
    code { Faker::Lorem.characters(3).upcase }
    name { Faker::Lorem.words(4, true).join ' ' }
  end

end
