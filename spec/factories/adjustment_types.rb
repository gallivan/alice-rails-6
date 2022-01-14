FactoryBot.define do

  factory :adjustment_type do
    code { Faker::Lorem.characters(number: 3).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :adjustment_type_fee, parent: :adjustment_type do
    code { 'FEE' }
    name { 'Fee Adjustment'}
  end

  factory :adjustment_type_msc, parent: :adjustment_type do
    code { 'MSC' }
    name { 'Miscellaneous Adjustment'}
  end

  factory :adjustment_type_com, parent: :adjustment_type do
    code { 'COM' }
    name { 'Commission Adjustment'}
  end

end
