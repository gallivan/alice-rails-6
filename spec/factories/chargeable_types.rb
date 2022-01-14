FactoryBot.define do

  factory :chargeable_type do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' ' }
  end

  factory :chargeable_type_srv, parent: :chargeable_type do
    code { 'SRV' }
    name { 'Service' }
  end

  factory :chargeable_type_exg, parent: :chargeable_type do
    code { 'EXG' }
    name { 'Exchange' }
  end

  factory :chargeable_type_clr, parent: :chargeable_type do
    code { 'CLR' }
    name { 'Clearing' }
  end

  factory :chargeable_type_brk, parent: :chargeable_type do
    code { 'BRK' }
    name { 'Brokerage' }
  end

  factory :chargeable_type_enm, parent: :chargeable_type do
    code { 'ENM' }
    name { 'Exchange Non-Member' }
  end

end
