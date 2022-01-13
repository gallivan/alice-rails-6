FactoryBot.define do

  factory :statement_adjustment do
    posted_on {"2016-04-10"}
    stated_on {"2016-04-10"}
    account
    account_code {account.code}
    charge_code {charge.code}
    journal_code {journal.code}
    currency_code {currency.code}
    amount {9.99}
    memo { Faker::Lorem.words(4, true).join ' '}
  end
end
