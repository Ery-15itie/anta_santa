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
  # バリデーションとヘルパーメソッド
  # =========================================================
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }

  def following?(other_user)
    following.include?(other_user)
  end
end
