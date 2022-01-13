json.array!(@charges) do |charge|
  json.extract! charge, :id, :account_id, :chargeable_id, :currency_id, :segregation_id, :amount, :memo, :posted_on, :as_of_on
  json.url charge_url(charge, format: :json)
end
