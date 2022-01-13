json.array!(@money_lines) do |money_line|
  json.extract! money_line, :id, :account_id, :currency_held_id, :currency_base_id, :currency_mark_id, :posted_on, :beginning_balance, :cash, :pnl_futures, :pnl_options, :adjustments, :rebates, :charges, :ledger_balance, :open_trade_equity, :cash_account_balance, :margin, :long_option_value, :short_option_value, :net_option_value, :net_liquidating_balance
  json.url money_line_url(money_line, format: :json)
end
