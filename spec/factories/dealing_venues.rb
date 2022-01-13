FactoryBot.define do

  factory :dealing_venue do
    code {Faker::Lorem.characters(3).upcase}
    name {Faker::Company.name}
    entity {create(:entity)}
    dealing_venue_type {find_or_create(:dealing_venue_type_sys)}
  end

  factory :dealing_venue_sfe, parent: :dealing_venue do
    code {'SFE'}
    name {'Sydney Futures Exchange'}
    entity {find_or_create(:entity_asx)}
  end

  factory :dealing_venue_cbt, parent: :dealing_venue do
    code {'CBT'}
    name {'Chicago Board of Trade'}
    entity {find_or_create(:entity_cbt)}
  end

  factory :dealing_venue_cme, parent: :dealing_venue do
    code {'CME'}
    name {'Chicago Mercantile Exchange'}
    entity {find_or_create(:entity_cme)}
  end

  factory :dealing_venue_comex, parent: :dealing_venue do
    code {'COMEX'}
    name {'Commodity Exchange'}
    entity {find_or_create(:entity_cme)}
  end

  factory :dealing_venue_globex, parent: :dealing_venue do
    code {'GLOBEX'}
    name {'CME Globex'}
    entity {find_or_create(:entity_cme)}
  end

  factory :dealing_venue_kcbt, parent: :dealing_venue do
    code {'KCBT'}
    name {'Kansas City Board of Trade'}
    entity {find_or_create(:entity_cme)}
  end

  factory :dealing_venue_nymex, parent: :dealing_venue do
    code {'NYMEX'}
    name {'New York Mercantile Exchange'}
    entity {find_or_create(:entity_nymex)}
  end

  factory :dealing_venue_dtb, parent: :dealing_venue do
    code {'DTB'}
    name {'Deutsche Terminborse'}
    entity {find_or_create(:entity_eurex)}
  end

  factory :dealing_venue_eurex, parent: :dealing_venue do
    code {'EUREX'}
    name {'Eurex'}
    entity {find_or_create(:entity_eurex)}
  end

  factory :dealing_venue_aex, parent: :dealing_venue do
    code {'AEX'}
    name {'Amsterdam Exchange'}
    entity {find_or_create(:entity_ice)}
  end

  factory :dealing_venue_csc, parent: :dealing_venue do
    code {'CSC'}
    name {'Coffee Sugar Cocoa'}
    entity {find_or_create(:entity_ice)}
  end

  factory :dealing_venue_ice, parent: :dealing_venue do
    code {'ICE'}
    name {'Inter-Continental Exchange'}
    entity {find_or_create(:entity_ice)}
  end

  factory :dealing_venue_icecl, parent: :dealing_venue do
    code {'ICECL'}
    name {'Inter-Continental Exchange Clearing'}
    entity {find_or_create(:entity_icecl)}
  end

  factory :dealing_venue_ifeu, parent: :dealing_venue do
    code {'IFEU'}
    name {'ICE Futures Europe'}
    entity {find_or_create(:entity_ifeu)}
  end

  factory :dealing_venue_wge, parent: :dealing_venue do
    code {'WGE'}
    name {'Winnipeg Grain Exchange'}
    entity {find_or_create(:entity_ifca)}
  end

  factory :dealing_venue_liffe, parent: :dealing_venue do
    code {'LIFFE'}
    name {'London International Financial Futures Exchange'}
    entity {find_or_create(:entity_liffe)}
  end

  factory :dealing_venue_matif, parent: :dealing_venue do
    code {'MATIF'}
    name {'Marché à Terme International de France'}
    entity {find_or_create(:entity_matif)}
  end

  factory :dealing_venue_monep, parent: :dealing_venue do
    code {'MONEP'}
    name {'Marché des Options Negociables de Paris'}
    entity {find_or_create(:entity_monep)}
  end

  factory :dealing_venue_nylf, parent: :dealing_venue do
    code {'NYLF'}
    name {'NYSE LIFFE'}
    entity {find_or_create(:entity_nylf)}
  end

  factory :dealing_venue_mgex, parent: :dealing_venue do
    code {'MGEX'}
    name {'Minneapolis Grain Exchange'}
    entity {find_or_create(:entity_mgex)}
  end

  factory :dealing_venue_nyce, parent: :dealing_venue do
    code {'NYCE'}
    name {'New York Cotton Exchange'}
    entity {find_or_create(:entity_nyce)}
  end

end
