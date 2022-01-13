RSpec.describe Currency, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  it "has a valid factory" do
    expect(build(:currency)).to be_valid
  end

  [:code, :name].each do |sym|
    it "is invalid without a #{sym}" do
      currency = build(:currency, sym => nil)
      currency.valid?
      expect(currency.errors[sym]).to include("can't be blank")
    end
  end

  it 'will not allow dupes names' do
    create(:currency, code: 'ABC', name: 'Foo')
    expect { create(:currency, code: 'XYZ', name: 'Foo') }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it 'will not allow dupes codes' do
    create(:currency, code: 'ABC', name: 'Foo')
    expect { create(:currency, code: 'ABC', name: 'Bar') }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it 'will test factories for supported currencies' do
    Currency::SUPPORTED.keys.each do |key|
      if Currency.find_by_code(key.upcase).blank?
        obj = create("currency_#{key}".to_sym)
        expect(obj).to be_a_kind_of(Currency)
        expect(obj.code).to eq(key.to_s.upcase)
      end
    end
  end

end
