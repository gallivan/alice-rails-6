FactoryBot.define do
  factory :ledger_entry do
    ledger
    ledger_entry_type
    account
    currency
    posted_on {"2015-12-13"}
    as_of_on {"2015-12-13"}
    amount {9.99}
    memo { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
