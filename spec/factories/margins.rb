FactoryBot.define do

  factory :margin do
    margin_type
    margin_calculator
    margin_status
    currency
    amount {300123.00}
  end

end
