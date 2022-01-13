FactoryBot.define do

  factory :journal_type do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Lorem.words(4, true).join ' '}
  end

  factory :journal_type_sole, parent: :journal_type do
    code {'SOLE'}
    name {'Sole Journal Type'}
  end

end
