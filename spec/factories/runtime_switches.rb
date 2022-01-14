FactoryBot.define do
  factory :runtime_switch do
    name {Faker::Lorem.words(number: 1, supplemental: true)}
    is_on {false}
    note {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

end
