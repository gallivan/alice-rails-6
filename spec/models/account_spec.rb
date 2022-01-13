RSpec.describe Account, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  it "Can build a dummy account" do
    expect(build_stubbed(:account)).to be_valid
  end

end