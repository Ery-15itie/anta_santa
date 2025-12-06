class User < ApplicationRecord
  # =========================================================
  # 認証機能 (Devise & JWT)
  # =========================================================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist 
  
  # =========================================================
  # 評価（お手紙）機能の関連 
  # =========================================================
  has_many :sent_evaluations, class_name: 'Evaluation', foreign_key: 'evaluator_id', dependent: :destroy
  has_many :received_evaluations, class_name: 'Evaluation', foreign_key: 'evaluated_user_id', dependent: :destroy

  # =========================================================
  # フォロー機能
  # =========================================================
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  # =========================================================
  # Heartory Home 機能
  # =========================================================
  has_many :emotion_logs, dependent: :destroy

  # =========================================================
  # サンタの書斎 (価値観パズル) 機能
  # =========================================================
  has_many :user_card_selections, dependent: :destroy
  has_many :selected_value_cards, through: :user_card_selections, source: :value_card

  # 心の航海日誌 (Magic Book) 機能 
  has_many :user_reflections, dependent: :destroy

  # =========================================================
  # バリデーション
  # =========================================================
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }

  # =========================================================
  # ヘルパーメソッド
  # =========================================================
  def following?(other_user)
    following.include?(other_user)
  end

  # =========================================================
  # 統計・集計ロジック
  # =========================================================
  
  # EmotionLogの連続投稿日数を計算
  # 複雑なSQLを避け、Ruby側で計算することで保守性と安定性を向上させています
  def emotion_streak
    # 1. ログの日付リストを取得（降順、重複なし、Date型に変換）
    # in_time_zoneを使うことで、アプリのタイムゾーン設定（東京など）を考慮した日付になります
    log_dates = emotion_logs.order(created_at: :desc)
                            .pluck(:created_at)
                            .map { |time| time.in_time_zone.to_date }
                            .uniq

    # 記録が一つもない場合は0
    return 0 if log_dates.empty?

    # 2. ストリークが「現役」かチェック
    # 最新の記録が「昨日」より前（一昨日以前）なら、既に途切れているので0を返す
    latest_date = log_dates.first
    return 0 if latest_date < Date.yesterday

    # 3. 連続日数をカウント
    streak = 0
    # カウントを開始する基準日（最新の記録日）
    check_date = latest_date

    log_dates.each do |date|
      if date == check_date
        streak += 1
        # 次のループでは「1日前」が存在するかを確認するため日付を戻す
        check_date -= 1.day 
      else
        # 日付が連続しなくなったらそこで終了
        break
      end
    end

    streak
  end
end
