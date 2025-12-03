FactoryBot.define do
  # --- 価値観パズル用 ---
  
  # カテゴリー（雲）
  factory :value_category do
    sequence(:name) { |n| "カテゴリー#{n}" }
    theme_color { "#4F46E5" }
    icon_key { "book" }
  end

  # カード（星）
  factory :value_card do
    association :value_category
    sequence(:name) { |n| "価値観#{n}" }
    description { "これはテスト用の価値観です" }
  end

  # ユーザーの選択
  factory :user_card_selection do
    association :user
    association :value_card
    timeframe { "current" }
  end

  # --- 心の航海日誌用 ---

  # 質問
  factory :reflection_question do
    sequence(:body) { |n| "質問その#{n}：サンタは好きですか？" }
    sequence(:position) { |n| n }
    category { "values" }
  end

  # 回答
  factory :user_reflection do
    association :user
    association :reflection_question
    answer { "はい、大好きです。" }
  end
end
