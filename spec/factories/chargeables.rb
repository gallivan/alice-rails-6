FactoryBot.define do
  factory :chargeable do
    chargeable_type
    claim_set
    currency
    amount {9.99}
    begun_on {'2017-02-26'}
    ended_on {'2017-02-26'}
  end

end
