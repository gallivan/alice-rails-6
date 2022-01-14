FactoryBot.define do

  factory :journal_entry do
    journal {find_or_create(:journal)}
    journal_entry_type {find_or_create(:journal_entry_type)}
    account {find_or_create(:account)}
    currency {find_or_create(:currency)}
    segregation {find_or_create(:segregation)}
    posted_on {"2016-04-09"}
    as_of_on {"2016-04-09"}
    amount {9.99}
    memo {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
