FactoryBot.define do
  factory :template_item do
    template { nil }
    title { "MyString" }
    description { "MyText" }
    item_type { "MyString" }
    weight { 1 }
  end
end
