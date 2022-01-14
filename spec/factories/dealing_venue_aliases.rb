FactoryBot.define do

  factory :dealing_venue_alias do
    system {create(:system)}
    dealing_venue {create(:dealing_venue)}
    code {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :dealing_venue_alias_aacc_02, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_globex)}
    code {'02'}
  end

  factory :dealing_venue_alias_aacc_04, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_comex)}
    code {'04'}
  end

  factory :dealing_venue_alias_aacc_05, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_liffe)}
    code {'05'}
  end

  factory :dealing_venue_alias_aacc_06, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_csc)}
    code {'06'}
  end

  factory :dealing_venue_alias_aacc_07, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_nymex)}
    code {'07'}
  end

  factory :dealing_venue_alias_aacc_08, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_kcbt)}
    code {'08'}
  end

  factory :dealing_venue_alias_aacc_09, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_mgex)}
    code {'09'}
  end

  factory :dealing_venue_alias_aacc_10, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_eurex)}
    code {'10'}
  end

  factory :dealing_venue_alias_aacc_11, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_wge)}
    code {'11'}
  end

  factory :dealing_venue_alias_aacc_13, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_nyce)}
    code {'13'}
  end

  factory :dealing_venue_alias_aacc_16, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_ifeu)}
    code {'16'}
  end

  factory :dealing_venue_alias_aacc_19, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_ifeu)}
    code {'19'}
  end

  factory :dealing_venue_alias_aacc_25, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_matif)}
    code {'25'}
  end

  factory :dealing_venue_alias_aacc_27, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_eurex)}
    code {'27'}
  end

  factory :dealing_venue_alias_aacc_28, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_aex)}
    code {'28'}
  end

  factory :dealing_venue_alias_aacc_9_N, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_nylf)}
    code {'9_N'}
  end

  factory :dealing_venue_alias_cmesys_cbt, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_cbt)}
    code {'CBT'}
  end

  factory :dealing_venue_alias_cmesys_cme, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_cme)}
    code {'CME'}
  end

  factory :dealing_venue_alias_cmesys_nymex, parent: :dealing_venue_alias do
    system {find_or_create(:system_aacc)}
    dealing_venue {find_or_create(:dealing_venue_nymex)}
    code {'NYMEX'}
  end

  factory :dealing_venue_alias_eod_ghf_eurex, parent: :dealing_venue_alias do
    system {find_or_create(:system_ghf)}
    dealing_venue {find_or_create(:dealing_venue_eurex)}
    code {'EUREX'}
  end

end
