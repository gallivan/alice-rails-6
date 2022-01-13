RSpec.describe JournalEntry, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe JournalEntry do

    it "has a valid factory" do
      expect(build(:journal_entry)).to be_valid
    end

    [:journal_id, :journal_entry_type_id, :account_id, :currency_id, :posted_on, :as_of_on, :amount, :memo].each do |sym|
      it "is invalid without a #{sym}" do
        journal_entry = build(:journal_entry, sym => nil)
        journal_entry.valid?
        expect(journal_entry.errors[sym]).to include("can't be blank")
      end
    end

    it "is reverseable" do
      journal_entry = create(:journal_entry)
      reverse_entry = Builders::JournalEntryBuilder.reverse(journal_entry, Date.today)

      # journal_attributes = journal_entry.attributes.except(:id, :amount, :posted_on).dup
      # reverse_attributes = reverse_entry.attributes.except(:id, :amount, :posted_on).dup
      # expect(reverse_attributes).to eq(journal_attributes)

      expect(reverse_entry.amount).to eq(journal_entry.amount * -1)
      expect(reverse_entry.posted_on).to eq(Date.today)
      expect(reverse_entry.memo).to eq("Reversed #{journal_entry.id}")
    end
  end

end
