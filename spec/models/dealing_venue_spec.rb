RSpec.describe DealingVenue, type: :model do

  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "a variety of valid DealingVenue factories" do
    specify 'dummy' do
      expect(build_stubbed(:dealing_venue)).to be_valid
    end

    specify 'AEX' do
      expect(build_stubbed(:dealing_venue_aex)).to be_valid
    end

    specify 'CBT' do
      expect(build_stubbed(:dealing_venue_cbt)).to be_valid
    end

    specify 'CME' do
      expect(build_stubbed(:dealing_venue_cme)).to be_valid
    end

    specify 'COMEX' do
      expect(build_stubbed(:dealing_venue_comex)).to be_valid
    end

    specify 'CSC' do
      expect(build_stubbed(:dealing_venue_csc)).to be_valid
    end

    specify 'DTB' do
      expect(build_stubbed(:dealing_venue_dtb)).to be_valid
    end

    specify 'EUREX' do
      expect(build_stubbed(:dealing_venue_eurex)).to be_valid
    end

    specify 'GLOBEX' do
      expect(build_stubbed(:dealing_venue_globex)).to be_valid
    end

    specify 'ICE' do
      expect(build_stubbed(:dealing_venue_ice)).to be_valid
    end

    specify 'ICECL' do
      expect(build_stubbed(:dealing_venue_icecl)).to be_valid
    end

    specify 'IFEU' do
      expect(build_stubbed(:dealing_venue_ifeu)).to be_valid
    end

    specify 'KCBT' do
      expect(build_stubbed(:dealing_venue_kcbt)).to be_valid
    end

    specify 'LIFFE' do
      expect(build_stubbed(:dealing_venue_liffe)).to be_valid
    end

    specify 'MATIF' do
      expect(build_stubbed(:dealing_venue_matif)).to be_valid
    end

    specify 'MGEX' do
      expect(build_stubbed(:dealing_venue_mgex)).to be_valid
    end

    specify 'MONEP' do
      expect(build_stubbed(:dealing_venue_monep)).to be_valid
    end

    specify 'NYCE' do
      expect(build_stubbed(:dealing_venue_nyce)).to be_valid
    end

    specify 'NYLF' do
      expect(build_stubbed(:dealing_venue_nylf)).to be_valid
    end

    specify 'NYMEX' do
      expect(build_stubbed(:dealing_venue_nymex)).to be_valid
    end

    specify 'NYCE' do
      expect(build_stubbed(:dealing_venue_nyce)).to be_valid
    end

    specify 'SFE' do
      expect(build_stubbed(:dealing_venue_sfe)).to be_valid
    end

    specify 'WGE' do
      expect(build_stubbed(:dealing_venue_wge)).to be_valid
    end
  end

end
