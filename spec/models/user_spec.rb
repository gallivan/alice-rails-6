RSpec.describe User, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end
  it "has a valid factory" do
    user = build_stubbed(:user)
    expect(user).to be_valid
  end
end
