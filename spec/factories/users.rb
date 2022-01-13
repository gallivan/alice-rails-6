FactoryBot.define do

  factory :user do
    sequence(:name) {|n| "User #{n}"}
    sequence(:email) { |n| "user_#{n}@example.com" }
    password {'let no methods be called before their time'}
    password_confirmation {'let no methods be called before their time'}
  end

end