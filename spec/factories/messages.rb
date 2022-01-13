FactoryBot.define do

  factory :message do
    source {"MyString"}
    add_attribute(:format) { 'MyString' }
    head {"MyString"}
    body {"MyText"}
    tail {"MyString"}
    handler {"MyString"}
    handled {false}
    error {"MyText"}
  end

end
