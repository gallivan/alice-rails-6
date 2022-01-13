FactoryBot.define do
  factory :statement_money_line do
    account
    account_code {account.code}
    stated_on {"2016-01-24"}
    posted_on {"2016-01-24"}
    held_currency_code {currency.code}
    base_currency_code {"USD"}
    beginning_balance {9.99}
    fees {9.99}
    commissions {9.99}
    pnl_futures {9.99}
    ledger_balance {9.99}
    open_trade_equity {9.99}
    cash_account_balance {9.99}
    net_liquidating_balance {9.99}
  end

end
