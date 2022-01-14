FactoryBot.define do

  factory :runtime_knob do
    name { Faker::Lorem.characters(number: 4).upcase }
    value { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
