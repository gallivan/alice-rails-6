RSpec.describe DealingVenueAlias, type: :model do
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
      expect(build_stubbed(:dealing_venue_alias)).to be_valid
    end

    specify 'AACC 02' do
      expect(build_stubbed(:dealing_venue_alias_aacc_02)).to be_valid
    end

    specify 'AACC 04' do
      expect(build_stubbed(:dealing_venue_alias_aacc_04)).to be_valid
    end

    specify 'AACC 05' do
      expect(build_stubbed(:dealing_venue_alias_aacc_05)).to be_valid
    end

    specify 'AACC 06' do
      expect(build_stubbed(:dealing_venue_alias_aacc_06)).to be_valid
    end

    specify 'AACC 07' do
      expect(build_stubbed(:dealing_venue_alias_aacc_07)).to be_valid
    end

    specify 'AACC 08' do
      expect(build_stubbed(:dealing_venue_alias_aacc_08)).to be_valid
    end

    specify 'AACC 09' do
      expect(build_stubbed(:dealing_venue_alias_aacc_09)).to be_valid
    end

    specify 'AACC 10' do
      expect(build_stubbed(:dealing_venue_alias_aacc_10)).to be_valid
    end

    specify 'AACC 11' do
      expect(build_stubbed(:dealing_venue_alias_aacc_11)).to be_valid
    end

    specify 'AACC 13' do
      expect(build_stubbed(:dealing_venue_alias_aacc_13)).to be_valid
    end

    specify 'AACC 16' do
      expect(build_stubbed(:dealing_venue_alias_aacc_16)).to be_valid
    end

    specify 'AACC 19' do
      expect(build_stubbed(:dealing_venue_alias_aacc_19)).to be_valid
    end

    specify 'AACC 25' do
      expect(build_stubbed(:dealing_venue_alias_aacc_25)).to be_valid
    end

    specify 'AACC 27' do
      expect(build_stubbed(:dealing_venue_alias_aacc_27)).to be_valid
    end

    specify 'AACC 28' do
      expect(build_stubbed(:dealing_venue_alias_aacc_28)).to be_valid
    end

    specify 'AACC 9_N' do
      expect(build_stubbed(:dealing_venue_alias_aacc_9_N)).to be_valid
    end

    specify 'CMEsys CBT' do
      expect(build_stubbed(:dealing_venue_alias_cmesys_cbt)).to be_valid
    end

    specify 'CMEsys CME' do
      expect(build_stubbed(:dealing_venue_alias_cmesys_cme)).to be_valid
    end

    specify 'CMEsys NYMEX' do
      expect(build_stubbed(:dealing_venue_alias_cmesys_nymex)).to be_valid
    end
  end

end
