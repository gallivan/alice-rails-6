json.array!(@journal_entry_types) do |journal_entry_type|
  json.extract! journal_entry_type, :id, :code, :name
  json.url journal_entry_type_url(journal_entry_type, format: :json)
end
