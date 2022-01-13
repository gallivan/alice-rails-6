RSpec.describe System, type: :model do
  describe "a variety of valid System factories" do
    before(:all) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start
      Rails.cache.clear
    end
    after(:all) do
      DatabaseCleaner.clean
    end
    specify 'dummy' do
      expect(build_stubbed(:system)).to be_valid
    end
    specify 'AACC' do
      expect(build_stubbed(:system_aacc)).to be_valid
    end
    specify 'ABN_MICS' do
      expect(build_stubbed(:system_abn_mics)).to be_valid
    end
    specify 'BKO' do
      expect(build_stubbed(:system_bko)).to be_valid
    end
    specify 'CQG' do
      expect(build_stubbed(:system_cqg)).to be_valid
    end
    specify 'QDL' do
      expect(build_stubbed(:system_qdl)).to be_valid
    end
    specify 'CME' do
      expect(build_stubbed(:system_cme)).to be_valid
    end
    specify 'CME EOD' do
      expect(build_stubbed(:system_cme_eod)).to be_valid
    end
  end
end
