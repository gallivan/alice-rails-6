FactoryBot.define do

  factory :journal do
    journal_type {find_or_create(:journal_type)}
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :journal_sole, parent: :journal do
    journal_type {find_or_create(:journal_type_sole)}
    code {'SOLE'}
    name {'Sole Journal'}
  end

end
