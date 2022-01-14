FactoryBot.define do

  factory :report do
    report_type
    format_type
    memo { Faker::Lorem.words(number: 4, supplemental: true).join ' '}
    location { '/' + Faker::Lorem.words(number: 4, supplemental: true).join('/')}
  end

end
