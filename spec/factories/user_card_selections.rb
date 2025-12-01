FactoryBot.define do
  factory :user_card_selection do
    user { nil }
    value_card { nil }
    timeframe { 1 }
    satisfaction { 1 }
    description { "MyText" }
  end
end
