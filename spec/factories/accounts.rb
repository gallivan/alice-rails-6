FactoryBot.define do

  factory :account do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Company.name }
    entity { find_or_create(:entity) }
    account_type { find_or_create(:account_type) }

    factory :account_regular do
      account_type { find_or_create(:account_type_regular) }
    end

    factory :account_non_member do
      account_type { find_or_create(:account_type_non_member) }
    end
  end

end
