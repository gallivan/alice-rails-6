FactoryBot.define do

  factory :dealing_venue_type do

    code {Faker::Lorem.characters(3).upcase}
    name {Faker::Lorem.words(4, true).join ' '}

    factory :dealing_venue_type_sys do
      code {'SYS'}
      name {'Electronic System'}
    end

  end

end
