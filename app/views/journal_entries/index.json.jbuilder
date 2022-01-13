json.array!(@journal_entries) do |journal_entry|
  json.extract! journal_entry, :id, :journal_id, :journal_entry_type_id, :account_id, :currency_id, :posted_on, :as_of_on, :amount, :memo
  json.url journal_entry_url(journal_entry, format: :json)
end
