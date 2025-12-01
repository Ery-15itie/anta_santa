FactoryBot.define do
  factory :user_reflection do
    user { nil }
    reflection_question { nil }
    answer { "MyText" }
  end
end
