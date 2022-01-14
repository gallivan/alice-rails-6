FactoryBot.define do

  factory :position_status do
    code { Faker::Lorem.characters(number: 4).upcase }
    name { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :position_status_opn, parent: :position_status do
    code { 'OPN' }
    name { 'Open'}
  end

  factory :position_status_clo, parent: :position_status do
    code { 'CLO' }
    name { 'Closed'}
  end

end
