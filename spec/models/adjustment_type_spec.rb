RSpec.describe AdjustmentType do

  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  it "has a valid factory" do
    expect(build_stubbed(:adjustment_type)).to be_valid
  end

end
