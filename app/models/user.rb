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
  
  # EmotionLogの連続投稿日数を計算（パフォーマンス最適化版）
  # 再帰的CTEを使用してDB側で計算することで、大量データでも高速に動作します
  def emotion_streak
    # アプリケーションのタイムゾーン設定（Tokyoなど）を取得
    timezone = Time.zone.name
    # 基準となる「昨日」の日付（ここより前で途切れていたらストリーク終了）
    yesterday = Date.current - 1.day

    # 再帰的CTEを使用した高速クエリ
    query = <<~SQL
      WITH RECURSIVE daily_logs AS (
        -- 1. ユーザーの記録を、指定タイムゾーンの日付に変換して取得（重複排除）
        SELECT DISTINCT date(created_at AT TIME ZONE :timezone) as log_date
        FROM emotion_logs
        WHERE user_id = :user_id
      ),
      streak_calculation AS (
        -- 2. 起点: 今日または昨日の記録があればスタート
        SELECT log_date
        FROM daily_logs
        WHERE log_date >= :yesterday
        ORDER BY log_date DESC
        LIMIT 1

        UNION ALL

        -- 3. 再帰: 1日前の日付を探し続ける
        SELECT d.log_date
        FROM daily_logs d
        INNER JOIN streak_calculation s ON d.log_date = s.log_date - INTERVAL '1 day'
      )
      -- 4. 連続した行数をカウント
      SELECT COUNT(*) FROM streak_calculation;
    SQL

    # SQLを実行して数値で返す
    result = ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.sanitize_sql_array([
        query, 
        { 
          user_id: id, 
          timezone: timezone,
          yesterday: yesterday 
        }
      ])
    )
    
    result.to_i
  end
end
