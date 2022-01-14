FactoryBot.define do

  factory :ledger_entry_type do
    code {Faker::Lorem.characters(number: 4).upcase}
    name {Faker::Lorem.words(number: 4, supplemental: true).join ' '}
  end

  factory :ledger_entry_type_adj, parent: :ledger_entry_type do
    code {'ADJ'}
    name {'Adjustments'}
  end

  factory :ledger_entry_type_beg, parent: :ledger_entry_type do
    code {'BEG'}
    name {'Beginging Balance'}
  end

  factory :ledger_entry_type_chg, parent: :ledger_entry_type do
    code {'CHG'}
    name {'Charge'}
  end

  factory :ledger_entry_type_com, parent: :ledger_entry_type do
    code {'COM'}
    name {'Commissions Balance'}
  end

  factory :ledger_entry_type_cshact, parent: :ledger_entry_type do
    code {'CSHACT'}
    name {'Cash Account Balance'}
  end

  factory :ledger_entry_type_fee, parent: :ledger_entry_type do
    code {'FEE'}
    name {'Fee Balance'}
  end

  factory :ledger_entry_type_leg, parent: :ledger_entry_type do
    code {'LEG'}
    name {'Ledger Balance'}
  end

  factory :ledger_entry_type_liq, parent: :ledger_entry_type do
    code {'LIQ'}
    name {'Liquidating Balance'}
  end

  factory :ledger_entry_type_npv, parent: :ledger_entry_type do
    code {'NPV'}
    name {'Net Present Value Balance'}
  end

  factory :ledger_entry_type_ote, parent: :ledger_entry_type do
    code {'OTE'}
    name {'Open Trade Equity Balance'}
  end

  factory :ledger_entry_type_pnlfut, parent: :ledger_entry_type do
    code {'PNLFUT'}
    name {'Futures Profit and Loss Balance'}
  end

end



