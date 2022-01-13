FactoryBot.define do

  factory :claim_type do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Lorem.words(4, true).join ' '}
  end

  factory :claim_type_future, parent: :claim_type do
    code {'FUT'}
    name {'Future'}
  end

end
