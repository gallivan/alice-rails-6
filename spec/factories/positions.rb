FactoryBot.define do

  factory :position do
    posted_on {"2015-12-22"}
    traded_on {"2015-12-22"}
    account
    claim
    price {9.99}
    price_traded {"9.99"}
    bot {10}
    sld {12}
    bot_off {0}
    sld_off {0}
    net {-2}
    ote {0.0}
    currency
    position_status
  end

end
