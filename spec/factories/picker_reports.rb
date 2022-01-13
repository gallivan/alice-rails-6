FactoryBot.define do

  factory :picker_report do
    posted_on { Date.today }
    kind {"MyString"}
    fate {"MyString"}
    data {"MyText"}
    goof_error {"MyText"}
    goof_trace {"MyText"}
  end

end
