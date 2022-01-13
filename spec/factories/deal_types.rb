FactoryBot.define do

  #
  # Concise explanation of complex model construction.
  #
  # http://blog.thefrontiergroup.com.au/2014/12/using-factorygirl-easily-create-complex-data-sets-rails/
  #

  factory :deal_type do

    trait :money_forward do
      code { 'MNY:FWD' }
      name { 'Money Forward' }
    end

    # default construction
    code { Faker::Lorem.characters(4).upcase }
    name { Faker::Lorem.words(4, true).join ' ' }

    factory :money_forward, traits: [:money_forward]
  end

end

