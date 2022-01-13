json.array!(@statement_adjustments) do |statement_adjustment|
  json.extract! statement_adjustment, :id, :posted_on, :stated_on, :account_id, :account_code, :commission_code, :journal_code, :currency_code, :amount, :memo
  json.url statement_adjustment_url(statement_adjustment, format: :json)
end
