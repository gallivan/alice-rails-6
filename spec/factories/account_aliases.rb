FactoryBot.define do

  factory :account_alias do
    system
    account
    code { Faker::Lorem.characters(number: 4).upcase }
  end

end
