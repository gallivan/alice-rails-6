FactoryBot.define do

  #
  # basic factory
  #
  factory :currency do
    code { Faker::Lorem.characters(number: 3).upcase } # TODO - sample from ISO codes
    name { Faker::Company.name } # TODO - use ISO name matching ISO code
  end

  #
  # build factories for supported currencies
  #
  Currency::SUPPORTED.keys.each do |key|
    factory "currency_#{key}", class: Currency do
      code {Currency::SUPPORTED[key][:code]}
      name {Currency::SUPPORTED[key][:name]}
    end
  end

end
