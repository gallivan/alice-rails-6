json.array!(@chargeables) do |chargeable|
  json.extract! chargeable, :id, :chargeable_type_id, :claim_set_id, :currency_id, :amount, :begun_on, :ended_on
  json.url chargeable_url(chargeable, format: :json)
end
