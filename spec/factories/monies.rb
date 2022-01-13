FactoryBot.define do

  factory :money do
    settled_on { 5.days.from_now }
    currency { Currency.find_by(code: 'USD') || FactoryBot.create(:currency_usd) }

    trait :monday_next do
      base = Money.next_weekday(Date.today)
      settled_on { Date.commercial((base).year, base.cweek, 1) }
    end

    trait :monday_week do
      base = Money.next_weekday(Date.today + 1.week)
      settled_on { Date.commercial((base).year, base.cweek, 1) }
    end

    trait :eur do
      currency { Currency.find_by_code('EUR') || create(:currency_eur) }
    end

    factory :money_1_usd_monday_next, traits: [:monday_next]
    factory :money_1_eur_monday_next, traits: [:monday_next, :eur]
  end

end
