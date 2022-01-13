FactoryBot.define do

  factory :statement_deal_leg_fill do
    account
    claim
    posted_on {"2016-01-24"}
    traded_on {"2016-01-24"}
    bot {5}
    sld {10}
    net {-5}
    price {9.99}
    price_traded {"9.99"}
  end

end
