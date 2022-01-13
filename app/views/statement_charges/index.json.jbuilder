json.array!(@statement_charges) do |statement_charge|
  json.extract! statement_charge, :id, :posted_on, :stated_on, :account_id, :account_code, :charge_code, :journal_code, :currency_code, :amount, :memo
  json.url statement_charge_url(statement_charge, format: :json)
end
