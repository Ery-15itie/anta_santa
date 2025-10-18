FactoryBot.define do
  factory :evaluation do
    evaluator { nil }
    evaluated_user { nil }
    template { nil }
    title { "MyString" }
    status { 1 }
    total_score { 1 }
  end
end
