FactoryBot.define do

  factory :system do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Company.name}
    entity {find_or_create(:entity)}
    system_type {find_or_create(:system_type)}
  end

  factory :system_aacc, parent: :system do
    code {'AACC'}
    name {'ABN AMRO Clearing Corporation'}
    entity {Entity.find_by_code('FORTIS') || create(:entity_fortis)}
    system_type {find_or_create(:system_type_clearing_broker)}
  end

  factory :system_abn_mics, parent: :system do
    code {'ABN_MICS'}
    name {'ABN AMRO Clearing Corporation Market Identification Codes'}
    entity {Entity.find_by_code('FORTIS') || create(:entity_fortis)}
    system_type {find_or_create(:system_type_clearing_broker)}
  end

  factory :system_bko, parent: :system do
    code {'BKO'}
    name {'Backoffice Entry'}
    entity {find_or_create(:entity_emm)}
    system_type {find_or_create(:system_type_house)}
  end

  factory :system_cme_eod, parent: :system do
    code {'CME_EOD_FILE'}
    name {'CME FIX EOD Files'}
    entity {find_or_create(:entity_cme)}
    system_type {find_or_create(:system_type_clearing)}
  end

  factory :system_cme, parent: :system do
    code {'CMEsys'}
    name {'CME System'}
    entity {find_or_create(:entity_cme)}
    system_type {find_or_create(:system_type_clearing)}
  end

  factory :system_cqg, parent: :system do
    code {'CQG'}
    name {'FACT Commodity Quote Graphics Data Factory'}
    entity {find_or_create(:entity_cqg)}
    system_type {find_or_create(:system_type_market_data)}
  end

  factory :system_qdl, parent: :system do
    code {'QDL'}
    name {'quandl.com'}
    entity {find_or_create(:entity_qdl)}
    system_type {find_or_create(:system_type_market_data)}
  end

  factory :system_ghf, parent: :system do
    code {'GHF'}
    name {'GH Financial'}
    entity {find_or_create(:entity_ghf)}
    system_type {find_or_create(:system_type_market_data)}
  end



end
