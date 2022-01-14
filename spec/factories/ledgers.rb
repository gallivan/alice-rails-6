FactoryBot.define do

  factory :ledger do
    ledger_type
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :ledger_sole, parent: :ledger do
    ledger_type {create(:ledger_type_sole)}
    code {'SOLE'}
    name {'Sole Ledger'}
  end

end
