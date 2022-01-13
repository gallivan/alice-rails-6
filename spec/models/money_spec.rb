RSpec.describe Money, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe Money do
    before(:all) do
      date = Money.next_weekday(Date.today)
      @monday_next = Date.commercial((date).year, date.cweek, 1)
    end

    it "has a valid factory" do
      expect(build(:money)).to be_valid
    end

    [:settled_on, :currency_id].each do |sym|
      it "is invalid without a #{sym}" do
        money = build(:money, sym => nil)
        money.valid?
        expect(money.errors[sym]).to include("can't be blank")
      end
    end

    it "has a valid factory for 1 USD settled next monday" do
      money = create(:money_1_usd_monday_next)
      expect(money.settled_on).to eq @monday_next
      expect(money.currency).to eq Currency.find_by(code: 'USD')
    end

  end
end
