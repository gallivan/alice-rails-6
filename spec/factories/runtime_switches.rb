FactoryBot.define do
  factory :runtime_switch do
    name {Faker::Lorem.words(1, true)}
    is_on {false}
    note {Faker::Lorem.words(4, true).join ' '}
  end

end
