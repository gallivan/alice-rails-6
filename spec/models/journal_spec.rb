RSpec.describe Journal, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe Journal do
    it "has a valid factory" do
      expect(build(:journal)).to be_valid
    end
    [:journal_type_id, :code, :name].each do |sym|
      it "is invalid without a #{sym}" do
        journal = build(:journal, sym => nil)
        journal.valid?
        expect(journal.errors[sym]).to include("can't be blank")
      end
    end
  end

end
