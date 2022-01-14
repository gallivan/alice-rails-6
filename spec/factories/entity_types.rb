FactoryBot.define do

  factory :entity_type do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' ' }

    factory :entity_type_individual do
      code { 'IND' }
      name { 'Individual' }
    end

    factory :entity_type_corporation do
      code { 'CRP' }
      name { 'Corporation' }
    end
  end

end
