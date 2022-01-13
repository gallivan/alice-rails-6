FactoryBot.define do

  factory :position_netting do
    claim
    account
    currency
    position_netting_type
    bot_position
    sld_position
    posted_on {"2015-12-22"}
    bot_price {101.75}
    sld_price {101.75}
    bot_price_traded {"101-24"}
    sld_price_traded {"101-24"}
    done {1}
    pnl {0.0}
  end

end

