FactoryBot.define do

  factory :adjustment do
    account
    adjustment_type
    journal_entry
    currency
    amount {9.99}
    posted_on {"2016-04-10"}
    memo {"MyString"}
  end

end
