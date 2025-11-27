FactoryBot.define do
  factory :emotion_log do
    association :user
    emotion { :joy }          # デフォルトは「喜び」
    intensity { 3 }           # 強さ3
    body { "テストの薪です" } # 本文 (noteではなくbody)
    magic_powder { :no_powder } # 魔法の粉なし

    # ネガティブ感情のパターン
    trait :negative do
      emotion { :sadness }
    end

    # 魔法の粉を使ったパターン
    trait :with_powder do
      emotion { :sadness }
      magic_powder { :copper }
    end
  end
end
