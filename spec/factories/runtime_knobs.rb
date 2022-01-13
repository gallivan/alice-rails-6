FactoryBot.define do

  factory :runtime_knob do
    name { Faker::Lorem.characters(4).upcase }
    value { Faker::Lorem.words(4, true).join ' '}
  end

end
