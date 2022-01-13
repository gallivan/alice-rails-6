FactoryBot.define do

  factory :deal_leg_fill do
    deal_leg
    kind {"DATA"}
    done {9.99}
    price {9.99}
    price_traded {9.99}
    posted_on {"2015-12-05"}
    traded_on {"2015-12-05"}
    traded_at {"2015-12-05 18:39:01"}
    system
    dealing_venue
    dealing_venue_done_id { Faker::Number.between(1_000_000, 9_000_000) }

    # factory :deal_outright_claim_money_1_usd_monday_next_bid_fill do
    #   dealing_venue
    #
    #   after(:build) do |deal_leg_fill|
    #     # deal = create(:deal_outright_claim_money_1_usd_monday_next_bid)
    #     deal
    #     deal_leg = deal.deal_legs.first
    #     deal_leg_fill.done = deal_leg.todo
    #     deal_leg_fill.price = deal_leg.todo_price
    #     deal_leg_fill.price_traded = deal_leg.todo_price
    #     deal_leg_fill.posted_on = Date.today
    #     deal_leg_fill.traded_on = Date.today
    #     deal_leg_fill.traded_at = Time.now
    #     deal_leg_fill.dealing_venue_done_id = Random.new.rand(1_000_000)
    #     deal_leg.deal_leg_fills << deal_leg_fill
    #     deal_leg.save!
    #   end
    #
    # end

  end

end


