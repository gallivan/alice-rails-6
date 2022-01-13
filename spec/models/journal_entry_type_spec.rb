RSpec.describe JournalEntryType do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "valid factories" do
    specify 'dummy venue' do
      expect(build_stubbed(:journal_entry_type)).to be_valid
    end

    specify 'adjustment' do
      expect(build_stubbed(:journal_entry_type_adj)).to be_valid
    end

    specify 'commission' do
      expect(build_stubbed(:journal_entry_type_com)).to be_valid
    end

    specify 'cash' do
      expect(build_stubbed(:journal_entry_type_csh)).to be_valid
    end

    specify 'fee' do
      expect(build_stubbed(:journal_entry_type_fee)).to be_valid
    end

    specify 'open trade equity' do
      expect(build_stubbed(:journal_entry_type_ote)).to be_valid
    end

    specify 'profit and loss' do
      expect(build_stubbed(:journal_entry_type_pnl)).to be_valid
    end
  end

end
