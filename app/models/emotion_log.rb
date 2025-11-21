class EmotionLog < ApplicationRecord
  # =========================================================
  # 関連付け
  # =========================================================
  belongs_to :user

  # =========================================================
  # ENUM（感情ラベルの定義）
  # =========================================================
  # 感情を整数としてDBに保存し、コード内でシンボルとして扱う
  enum emotion: { 
    happy: 0, 
    joy: 1,      # 喜び
    sad: 2, 
    anger: 3,    # 怒り
    fear: 4,     # 恐れ
    calm: 5,     # 穏やか
    anxious: 6,  # 不安
    tired: 7,    # 疲労
    neutral: 8   # 普通/無感情
  }

  # =========================================================
  # バリデーション
  # =========================================================
  # emotionはenumで定義した値に含まれることを自動でチェック
  validates :emotion, presence: true
  
  # 強度は1から5の必須項目
  validates :intensity, presence: true, numericality: { 
    in: 1..5, 
    only_integer: true,
    message: "は1から5の間である必要があります"
  } 
  
  # bodyは500文字の制限を設ける
  validates :body, length: { maximum: 500 }, allow_blank: true
end
