json.array!(@charges_journal_entries) do |charges_journal_entry|
  json.extract! charges_journal_entry, :id, :charge_id, :journal_entry_id
  json.url charges_journal_entry_url(charges_journal_entry, format: :json)
end
