FactoryBot.define do

  factory :booker_report do
    kind {"MyString"}
    fate {"MyString"}
    data {"MyText"}
    goof_error {"MyText"}
    goof_trace {"MyText"}
    posted_on { Date.today }
  end

end
