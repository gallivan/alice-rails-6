json.array!(@ledger_entries) do |ledger_entry|
  json.extract! ledger_entry, :id, :ledger_id, :ledger_entry_type_id, :account_id, :currency_id, :posted_on, :as_of_on, :amount, :memo
  json.url ledger_entry_url(ledger_entry, format: :json)
end
