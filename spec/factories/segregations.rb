FactoryBot.define do

  factory :segregation do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
    note {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :segregation_segd, parent: :segregation do
    code {'SEGD'}
    name {'SEG'}
    note {'Segregated'}
  end

  factory :segregation_segn, parent: :segregation do
    code {'SEGN'}
    name {'NON'}
    note {'Non-Segregated'}
  end

  factory :segregation_segu, parent: :segregation do
    code {'SEGU'}
    name {'UKN'}
    note {'Unknown Segregated'}
  end

  factory :segregation_seg7, parent: :segregation do
    code {'SEG7'}
    name {'30.7'}
    note {'30.7 Segregated'}
  end

  factory :segregation_none, parent: :segregation do
    code {'NONE'}
    name {'NONE'}
    note {'Not Segregated'}
  end

  factory :segregation_base, parent: :segregation do
    code {'SEGB'}
    name {'Base'}
    note {'Base Segregated'}
  end

end
