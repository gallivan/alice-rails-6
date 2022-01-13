RSpec.describe SystemType do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end
  describe "a variety of SystemTypes have valid factories" do
    specify {expect(build_stubbed(:system_type)).to be_valid}
    specify {expect(build_stubbed(:system_type_clearing_broker)).to be_valid}
    specify {expect(build_stubbed(:system_type_market_data)).to be_valid}
    specify {expect(build_stubbed(:system_type_clearing)).to be_valid}
    specify {expect(build_stubbed(:system_type_house)).to be_valid}
  end
end
