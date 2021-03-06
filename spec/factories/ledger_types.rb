FactoryBot.define do

  factory :ledger_type do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :ledger_type_sole, parent: :ledger_type do
    code { 'SOLE' }
    name { 'Sole ledger type'}
  end

end
