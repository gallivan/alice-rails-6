json.array!(@ledger_entry_types) do |ledger_entry_type|
  json.extract! ledger_entry_type, :id, :code, :name
  json.url ledger_entry_type_url(ledger_entry_type, format: :json)
end
