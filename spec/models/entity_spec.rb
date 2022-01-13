RSpec.describe Entity, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Rails.cache.clear
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "a variety of valid Entity factories" do
    specify {expect(build_stubbed(:entity)).to be_valid}
    specify {expect(build_stubbed(:entity_individual)).to be_valid}
    specify {expect(build_stubbed(:entity_corporation)).to be_valid}
    specify {expect(build_stubbed(:entity_emm)).to be_valid}
    specify {expect(build_stubbed(:entity_fortis)).to be_valid}
    specify {expect(build_stubbed(:entity_cme)).to be_valid}
    specify {expect(build_stubbed(:entity_cbt)).to be_valid}
    specify {expect(build_stubbed(:entity_ice)).to be_valid}
    specify {expect(build_stubbed(:entity_icecl)).to be_valid}
    specify {expect(build_stubbed(:entity_eurex)).to be_valid}
    specify {expect(build_stubbed(:entity_matif)).to be_valid}
    specify {expect(build_stubbed(:entity_monep)).to be_valid}
    specify {expect(build_stubbed(:entity_asx)).to be_valid}
    specify {expect(build_stubbed(:entity_mgex)).to be_valid}
    specify {expect(build_stubbed(:entity_nyse)).to be_valid}
    specify {expect(build_stubbed(:entity_nymex)).to be_valid}
    specify {expect(build_stubbed(:entity_qdl)).to be_valid}
    specify {expect(build_stubbed(:entity_ifca)).to be_valid}
    specify {expect(build_stubbed(:entity_ifeu)).to be_valid}
    specify {expect(build_stubbed(:entity_liffe)).to be_valid}
    specify {expect(build_stubbed(:entity_nyce)).to be_valid}
    specify {expect(build_stubbed(:entity_cqg)).to be_valid}
  end

end
