FactoryBot.define do
  factory :template do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    is_public { false }
  end
end
