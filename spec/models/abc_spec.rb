#
# structure reminder
#
RSpec.describe Account, type: :model do
  before :all do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    @code = '00123'
    firm = FactoryBot.create(:entity_emm)
    FactoryBot.create(:account, entity: firm, code: @code, name: firm.name + " account #{@code}")
    @account = Account.find_by_code(@code)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  context "first context" do
    it 'should test this' do
      expect(@account.code).to eql(@code)
    end

    it 'should test that' do
      expect(@account.code).to eql(@code)
    end
  end

  context "second context" do
    it 'should test this too' do
      expect(@account.code).to eql(@code)
    end

    it 'should test that too' do
      expect(@account.code).to eql(@code)
    end
  end

end