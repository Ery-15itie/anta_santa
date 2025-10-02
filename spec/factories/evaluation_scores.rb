FactoryBot.define do
  factory :evaluation_score do
    evaluation { nil }
    template_item { nil }
    score { 1 }
    comment { "MyText" }
  end
end
