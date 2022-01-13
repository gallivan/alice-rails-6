RSpec.describe Deal, type: :model do

  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  it "has a valid factory" do
    expect(build(:deal)).to be_valid
  end

  [:deal_type_id, :account_id, :posted_on, :traded_on, :todo, :todo_price].each do |sym|
    it "is invalid without a #{sym}" do
      deal = build(:deal, sym => nil)
      deal.valid?
      expect(deal.errors[sym]).to include("can't be blank")
    end
  end

  #
  # some work to do here
  # but now is not the time
  #

  # it "can bid for 1 USD for monday next" do
  #   deal = create(:deal_outright_claim_money_1_usd_monday_next_bid, todo: +1)
  #
  #   puts '*' * 80
  #   puts deal.attributes
  #   puts deal.deal_legs.first.claim.code
  #   puts '+' * 80
  #
  #   # check the deal
  #   expect(deal.todo).to eq +1
  #   expect(deal.todo_price).to eq 0.98
  #   expect(deal.deal_legs.count).to eq +1
  #
  #   # check the leg
  #   expect(deal.deal_legs.first.todo).to eq +1
  #   expect(deal.deal_legs.first.todo).to eq deal.todo
  #   expect(deal.deal_legs.first.todo_price).to eq deal.todo_price
  #
  #   # check the claim
  #   expect(deal.deal_legs.first.claim.size).to eq 1
  #   expect(deal.deal_legs.first.claim.claimable_type).to eq 'Money'
  #   expect(deal.deal_legs.first.claim.claimable.currency.code).to eq 'USD'
  # end
  #
  # it "can ask for 1 USD for monday next" do
  #   deal = create(:deal_outright_claim_money_1_usd_monday_next_ask, todo: -1)
  #
  #   # check the deal
  #   expect(deal.todo).to eq -1
  #   expect(deal.todo_price).to eq 0.98
  #   expect(deal.deal_legs.count).to eq 1
  #
  #   # check the leg
  #   expect(deal.deal_legs.first.todo).to eq -1
  #   expect(deal.deal_legs.first.todo).to eq deal.todo
  #   expect(deal.deal_legs.first.todo_price).to eq deal.todo_price
  #
  #   # check the claim
  #   expect(deal.deal_legs.first.claim.size).to eq 1
  #   expect(deal.deal_legs.first.claim.claimable_type).to eq 'Money'
  #   expect(deal.deal_legs.first.claim.claimable.currency.code).to eq 'USD'
  # end

end


