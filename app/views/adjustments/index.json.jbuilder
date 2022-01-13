json.array!(@adjustments) do |adjustment|
  json.extract! adjustment, :id, :account_id, :adjustment_type_id, :journal_entry_id, :amount, :currency_id, :posted_on, :memo
  json.url adjustment_url(adjustment, format: :json)
end
