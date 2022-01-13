FactoryBot.define do

  factory :claim_mark do
    system
    claim
    posted_on {"2016-01-01"}
    mark {9.99}
  end

end
