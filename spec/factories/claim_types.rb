FactoryBot.define do

  factory :claim_type do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :claim_type_future, parent: :claim_type do
    code {'FUT'}
    name {'Future'}
  end

end
