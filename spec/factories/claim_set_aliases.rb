FactoryBot.define do

  factory :claim_set_alias do
    system
    claim_set
    code { Faker::Lorem.characters(4).upcase }
  end

end
