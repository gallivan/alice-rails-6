FactoryBot.define do

  factory :account_type do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}

    factory :account_type_regular do
      code {'REG'}
      name {'Regular'}
    end

    factory :account_type_group do
      code {'GRP'}
      name {'Group'}
    end

    factory :account_type_non_member do
      code {'ENM'}
      name {'Exchange Non-Member'}
    end

  end

end

