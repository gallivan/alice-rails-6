FactoryBot.define do

  factory :deal_leg do
    deal
    claim
    todo {9.99}
    done {9.99}
    todo_price {9.99}
    done_price {9.99}

    #
    # create this via a deal only
    #

    # factory :deal_leg_claim_money_1_usd_monday_next, class: DealLeg do
    #   claim { Claim.first || create(:claim_money_1_usd_monday_next) }
    # end

  end

end
