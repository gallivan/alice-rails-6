RSpec.describe Future, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end
  it "has a valid factory" do
    future = build_stubbed(:future)
    future.claim.claimable = future # todo - can i avoid this....
    expect(future).to be_valid
    expect(future.claim).to be_valid
  end
end
