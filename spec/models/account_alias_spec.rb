RSpec.describe AccountAlias do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  it "has a valid factory" do
    expect(build_stubbed(:account_alias)).to be_valid
  end

  [:system_id, :account_id, :code].each do |sym|
    it "is invalid without a #{sym}" do
      account_alias = build(:account_alias, sym => nil)
      account_alias.valid?
      expect(account_alias.errors[sym]).to include("can't be blank")
    end
  end
  
end
