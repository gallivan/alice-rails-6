RSpec.describe Claim, type: :model do

  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe Claim do

    it "has a valid factory" do
      claim = build_stubbed(:claim)
      future = build_stubbed(:future, claimable_id: claim.id)
      # future.claima = claim
      claim.claimable = future
      puts claim.inspect
      puts "claimable found" if claim.claimable.blank?
      puts claim.claimable.inspect
      # expect(build_stubbed(:claim)).to be_valid
    end

    # it "builds claim_money_1_usd" do
    #   build(:claim_money_1_usd)
    # end

    # it "builds claim_money_1_usd_monday_next" do
    #   build(:claim_money_1_usd_monday_next)
    # end

    # it "builds claim_money_1_eur_monday_next" do
    #   build(:claim_money_1_eur_monday_next)
    # end

  end

end
