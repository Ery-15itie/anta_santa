FactoryBot.define do
  # ------------------------------------------------
  # 1. 評価項目 (TemplateItem) の定義
  # ------------------------------------------------
  factory :template_item do
    # デフォルト値
    sequence(:title) { |n| "テスト項目#{n}" }
    category { "テストカテゴリ" }
    item_type { "checkbox" }
    position { 1 }
    weight { 1 }
    
    # テンプレートと紐付ける
    association :template
  end

  # ------------------------------------------------
  # 2. 評価シート (Template) の定義
  # ------------------------------------------------
  factory :template do
    title { "サンタさん通知表" }
    description { "テスト用の評価シートです" }
    is_public { true }
    association :user

    # テンプレート作成後に、テストで探している具体的な項目を自動生成する
    after(:create) do |template|
      # テストコードの `check '行動力がすごい'` を通すためのデータ
      create(:template_item, title: "行動力がすごい", category: "行動力", template: template)
      
      # その他のダミーデータ
      create(:template_item, title: "笑顔が素敵", category: "マインド", template: template)
    end
  end
end
