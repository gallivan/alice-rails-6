FactoryBot.define do

  factory :system_type do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Lorem.words(4, true).join ' '}

    factory :system_type_clearing_broker do
      code {'BRK'}
      name {'Clearing Broker System'}
    end

    factory :system_type_market_data do
      code {'MKTDAT'}
      name {'Market Data System'}
    end

    factory :system_type_clearing do
      code {'CLR'}
      name {'Clearing System'}
    end

    factory :system_type_house do
      code {'HOU'}
      name {'House System'}
    end

  end

end
