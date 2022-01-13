RSpec.describe EntityType do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end
  describe "Dummy, Individual and Corporation have valid factories" do
    specify {expect(build_stubbed(:entity_type)).to be_valid}
    specify {expect(build_stubbed(:entity_type_individual)).to be_valid}
    specify {expect(build_stubbed(:entity_type_corporation)).to be_valid}
  end
end
