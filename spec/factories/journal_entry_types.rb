FactoryBot.define do

  factory :journal_entry_type do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :journal_entry_type_adj, parent: :journal_entry_type do
    code {'ADJ'}
    name {'Adjustment'}
  end

  factory :journal_entry_type_csh, parent: :journal_entry_type do
    code {'CSH'}
    name {'Cash'}
  end

  factory :journal_entry_type_fee, parent: :journal_entry_type do
    code {'FEE'}
    name {'Fee'}
  end

  factory :journal_entry_type_com, parent: :journal_entry_type do
    code {'COM'}
    name {'Commission'}
  end
  factory :journal_entry_type_pnl, parent: :journal_entry_type do
    code {'PNL'}
    name {'Profit and Loss'}
  end

  factory :journal_entry_type_ote, parent: :journal_entry_type do
    code {'OTE'}
    name {'Open Trade Equity'}
  end

end

