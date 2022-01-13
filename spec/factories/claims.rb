FactoryBot.define do

  # factory :claim_future, class: 'Future' do
  #   claim.association(:topic, name: 'Future')
  # end

  factory :claim do

    # trait :for_future do
    #   association(:claimable, factory: :future)
    # end

    claimable_type {build_stubbed(:claim_type_future)}

    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Lorem.words(4, true).join ' '}

    entity {build_stubbed(:entity)}

    claim_set {build_stubbed(:claim_set)}
    claim_type {build_stubbed(:claim_type)}

    size {Faker::Number.between(1, 1_000_000)}
    point_value {Faker::Number.between(1, 100)}
    point_currency {build_stubbed(:currency_usd)}

    # factory :claim_money_1_usd do
    #   claim_type {ClaimType.first || build_stubbed(:claim_type)}
    #   claim_set {ClaimSet.first || build_stubbed(:claim_set)}
    #   entity {Entity.first || build_stubbed(:entity)}
    #   claimable_type {"Money"}
    #   size {1}
    #   point_value {1}
    #
    #   # factory :claim_money_1_usd_monday_next, class: Claim do
    #   #   code {'USD'}
    #   #   name {'United States Dollar'}
    #   #   point_currency {Currency.usd || build_stubbed(:currency_usd)}
    #   #   claimable {build_stubbed(:money_1_usd_monday_next)}
    #   # end
    #   #
    #   # factory :claim_money_1_eur_monday_next, class: Claim do
    #   #   code {'EUR'}
    #   #   name {'European Euro'}
    #   #   point_currency {Currency.eur || build_stubbed(:currency_eur)}
    #   #   claimable {build_stubbed(:money_1_eur_monday_next)}
    #   # end
    # end

  end

end
