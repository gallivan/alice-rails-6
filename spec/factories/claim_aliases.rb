FactoryBot.define do

  factory :claim_alias do
    system
    claim
    code { Faker::Lorem.characters(number: 4).upcase }
  end

end
