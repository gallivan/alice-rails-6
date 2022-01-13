FactoryBot.define do

  factory :future do
    claim {build_stubbed(:claim)}
    expires_on {"2015-12-27"}
    claimable_id {self.claim.id}
  end

end
