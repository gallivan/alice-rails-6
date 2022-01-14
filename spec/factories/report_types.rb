FactoryBot.define do

  factory :report_type do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
