class EmotionLog < ApplicationRecord
  belongs_to :user

  # =========================================================
  # ENUM定義（感情と魔法の粉）
  # =========================================================
  
  # 1. 感情の種類
  enum emotion: {
    joy: 10,        # 😊 嬉しい
    calm: 11,       # 😌 穏やか
    love: 12,       # 🥰 愛おしい
    excited: 13,    # ✨ ワクワク
    
    normal: 20,     # 😐 普通
    thinking: 21,   # 🤔 考え中
    surprise: 22,   # 😮 驚き
    
    sadness: 30,    # 😔 悲しい
    anxiety: 31,    # 😰 不安
    anger: 32,      # 😤 怒り
    empty: 33       # 😞 虚しい
  }, _prefix: true

  # 2. 魔法の粉 (炎色反応)
  enum magic_powder: {
    no_powder: 0, 
    copper: 1,    # 銅
    lithium: 2,   # リチウム
    sodium: 3,    # ナトリウム
    barium: 4     # バリウム
  }, _prefix: true

  # =========================================================
  # バリデーション
  # =========================================================
  validates :emotion, presence: true
  
  # 強度は1〜5の範囲
  validates :intensity, presence: true, numericality: { 
    in: 1..5, 
    only_integer: true 
  }
  
  # メモ (bodyに統一済み)
  validates :body, length: { maximum: 200 }, allow_blank: true

  # =========================================================
  # スコープ
  # =========================================================
  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }

  # =========================================================
  # ロジックメソッド
  # =========================================================
  
  def self.current_fire_state(user)
    todays_logs = user.emotion_logs.today
    latest_log = user.emotion_logs.recent.first

    # 1. 炎の大きさ
    total_intensity = todays_logs.sum(:intensity)
    fire_size = 1.0 + (todays_logs.count * 0.2) + (total_intensity * 0.1)
    fire_size = [[fire_size, 5.0].min, 0.5].max

    # 2. 炎の色
    # 最新のログがあれば色を決定
    fire_color = if latest_log.nil?
                   'normal'
                 # no_powder 以外なら魔法の色
                 elsif latest_log.magic_powder != 'no_powder' 
                   latest_log.magic_powder
                 else
                   latest_log.emotion
                 end

    # 3. 炎の温度
    fire_temperature = 36 + (todays_logs.count * 2) + total_intensity

    {
      size: fire_size,
      color: fire_color,
      temperature: fire_temperature
    }
  end
end
