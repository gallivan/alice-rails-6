RSpec.describe AccountType do

  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "Dummy, Regular and Group have valid factories" do
    specify {expect(build_stubbed(:account_type)).to be_valid}
    specify {expect(build_stubbed(:account_type_group)).to be_valid}
    specify {expect(build_stubbed(:account_type_regular)).to be_valid}
  end

end
