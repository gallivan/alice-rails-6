FactoryBot.define do

  factory :report_type do
    code { Faker::Lorem.characters(4).upcase }
    name { Faker::Lorem.words(4, true).join ' '}
  end

end
