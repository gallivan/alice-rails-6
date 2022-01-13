# gilt

f = {
    "expires_on" => Date.parse('2020-03-25'),
    "code" => "LIFFE:RH19",
}

c = {
    "claim_set_id" => 24,
    "claim_type_id" => 2,
    "entity_id" => 4,
    "claimable_type" => "Future",
    "code" => "LIFFE:RH20",
    "name" => "Long Gilt Futures Mar 2020",
    "size" => 0.1e4,
    "point_value" => 0.1e4,
    "point_currency_id" => 3
}

claim = Claim.build(c)
future = Future.build(f)
claim.claimable = future
if claim.valid?
  claim.save!
else
  puts 'Validation Errors:'
  claim.errors.messages.each do |message|
    puts message
  end
end
