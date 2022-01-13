FactoryBot.define do

  factory :entity do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Company.name}
    entity_type {find_or_create(:entity_type)}
  end

  factory :entity_individual, parent: :entity do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Company.name}
    entity_type {find_or_create(:entity_type_individual)}
  end

  factory :entity_corporation, parent: :entity do
    code {Faker::Lorem.characters(4).upcase}
    name {Faker::Company.name}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_emm, parent: :entity do
    code {'EMM'}
    name {'Eagle Market Makers'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_fortis, parent: :entity do
    code {'FORTIS'}
    name {'Fortis'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_cme, parent: :entity do
    code {'CME'}
    name {'Chicago Mercantile Exchange'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_cbt, parent: :entity do
    code {'CBT'}
    name {'Chicago Board of Trade'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_ice, parent: :entity do
    code {'ICE'}
    name {'Inter-Continental Commodity Exchange'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_icecl, parent: :entity do
    code {'ICECL'}
    name {'Inter-Continental Commodity Exchange - Clearing'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_eurex, parent: :entity do
    code {'EUREX'}
    name {'Eurex'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_matif, parent: :entity do
    code {'MATIF'}
    name {'Marché à Terme International de France'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_monep, parent: :entity do
    code {'MONEP'}
    name {'Marché des Options Negociables de Paris'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_asx, parent: :entity do
    code {'ASX'}
    name {'Australian Securities Exchange'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_mgex, parent: :entity do
    code {'MGEX'}
    name {'Minniapolis Grain Exchange'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_nyse, parent: :entity do
    code {'NYSE_EURONEXT'}
    name {'NYSE Euronext'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_nylf, parent: :entity do
    code {'NYLF'}
    name {'NYSE LIFFE'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_nymex, parent: :entity do
    code {'NYMEX'}
    name {'New York Mercantile Exchange'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_qdl, parent: :entity do
    code {'QDL'}
    name {'Quandl (quandl.com)'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_ifca, parent: :entity do
    code {'IFCA'}
    name {'ICE Futures Canada'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_ifeu, parent: :entity do
    code {'IFEU'}
    name {'ICE Futures Europe'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_liffe, parent: :entity do
    code {'LIFFE'}
    name {'London International Financial Futures Exchange'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_nyce, parent: :entity do
    code {'NYCE'}
    name {'New York Cotton Exchange [ICE]'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_cqg, parent: :entity do
    code {'CQG'}
    name {'Commodity Quote Graphics'}
    entity_type {find_or_create(:entity_type_corporation)}
  end

  factory :entity_ghf, parent: :entity do
    code {'GHF'}
    name {'GH Financial'}
    entity_type {find_or_create(:entity_type_corporation)}
  end



end
