class UserCardSelection < ApplicationRecord
  belongs_to :user
  belongs_to :value_card

  # 時間軸の定義
  enum timeframe: { past: 0, current: 1, future: 2 }

  # バリデーション
  validates :timeframe, presence: true
  
  # 同じユーザーが、同じ時間軸で、同じカードを二重登録できないようにする設定
  validates :value_card_id, uniqueness: { 
    scope: [:user_id, :timeframe], 
    message: "はこの時間軸ですでに選択されています" 
  }
end
