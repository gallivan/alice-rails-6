FactoryBot.define do

  factory :entity_alias do
    system {create(:system)}
    entity {create(:entity)}
    code {Faker::Lorem.characters(number: 3).upcase}
  end

  factory :entity_alias_cme_cbt, parent: :entity_alias do
    system {find_or_create(:system_cme)}
    entity {find_or_create(:entity_cbt)}
    code {'CBT'}
  end

  factory :entity_alias_cme_cme, parent: :entity_alias do
    system {find_or_create(:system_cme)}
    entity {find_or_create(:entity_cme)}
    code {'CME'}
  end

end
