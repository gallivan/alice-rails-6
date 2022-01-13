FactoryBot.define do
  factory :charge do
    account
    chargeable
    currency
    segregation
    amount {9.99}
    memo {1}
    posted_on {'2017-02-26'}
    as_of_on {'2017-02-26'}
  end

end
