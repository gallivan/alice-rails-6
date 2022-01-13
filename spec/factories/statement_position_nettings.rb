FactoryBot.define do

  factory :statement_position_netting do
    account
    posted_on {"2016-01-24"}
    account_code {account.code}
    claim_code {claim.code}
    netting_code {"MyString"}
    bot_price_traded {9.99}
    sld_price_traded {9.99}
    done {9.99}
    pnl {9.99}
    currency_code {currency.code}
  end

end
