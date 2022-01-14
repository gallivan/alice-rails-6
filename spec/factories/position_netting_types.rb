FactoryBot.define do

  factory :position_netting_type do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :position_netting_type_sch, parent: :position_netting_type do
    code {'SCH'}
    name {'Scratch Trade'}
  end

  factory :position_netting_type_day, parent: :position_netting_type do
    code {'DAY'}
    name {'Day Trade'}
  end

  factory :position_netting_type_ovr, parent: :position_netting_type do
    code {'OVR'}
    name {'Overnight Trade'}
  end

end


