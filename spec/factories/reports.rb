FactoryBot.define do

  factory :report do
    report_type
    format_type
    memo { Faker::Lorem.words(4, true).join ' '}
    location { '/' + Faker::Lorem.words(4, true).join('/')}
  end

end
