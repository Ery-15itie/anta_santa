FactoryBot.define do
  factory :template_item do
    title { "テスト項目" }
    category { "テストカテゴリ" }
    association :template
    item_type { "checkbox" }
  end
end
