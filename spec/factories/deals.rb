FactoryBot.define do

  factory :deal do
    deal_type {find_or_create(:deal_type)}
    account {find_or_create(:account)}
    posted_on {"2015-12-05"}
    traded_on {"2015-12-05"}
    todo {9.99}
    todo_price {9.99}

    # trait :money_forward do
    #   deal_type {DealType.find_by_code('MNY:FWD') || create(:money_forward)}
    # end
    #
    # factory :deal_outright_claim_money_1_usd_monday_next_bid, class: Deal do
    #   deal_type {DealType.find_by_code('MNY:FWD') || create(:money_forward)}
    #   account {Account.first || create(:account)}
    #   posted_on Date.today
    #   traded_on Date.today
    #   todo +1
    #   todo_price 0.98
    #
    #   after(:create) do |deal|
    #     deal.deal_legs << build(:deal_leg_claim_money_1_usd_monday_next, deal: deal, todo: deal.todo, todo_price: deal.todo_price)
    #   end
    # end
    #
    # factory :deal_outright_claim_money_1_usd_monday_next_ask, class: Deal do
    #   deal_type {DealType.find_by_code('MNY:FWD') || create(:money_forward)}
    #   account {Account.first || create(:account)}
    #   posted_on Date.today
    #   traded_on Date.today
    #   todo -1
    #   todo_price 0.98
    #
    #   after(:create) do |deal|
    #     deal.deal_legs << build(:deal_leg_claim_money_1_usd_monday_next, deal: deal, todo: deal.todo, todo_price: deal.todo_price)
    #   end
    # end

  end

end
