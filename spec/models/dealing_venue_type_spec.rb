RSpec.describe DealingVenueType do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "valid Dummy and Electronic factories" do
    specify 'dummy venue' do
      expect(build_stubbed(:dealing_venue_type)).to be_valid
    end

    specify 'electronic venue' do
      expect(build_stubbed(:dealing_venue_type_sys)).to be_valid
    end
  end

end
