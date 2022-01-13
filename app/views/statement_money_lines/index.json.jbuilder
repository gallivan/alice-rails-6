json.array!(@statement_money_lines) do |statement_money_line|
  json.extract! statement_money_line, :id, :stated_on, :posted_on, :account_id, :account_code, :held_currency_code, :base_currency_code, :beginning_balance, :pnl_futures, :ledger_balance, :open_trade_equity, :cash_account_balance, :net_liquidating_balance
  json.url statement_money_line_url(statement_money_line, format: :json)
end
