class User < ApplicationRecord
  # =========================================================
  # 認証機能 (Devise & JWT)
  # =========================================================
  # DeviseのJWT認証を有効化し、失効戦略として JwtDenylist クラスを指定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist 
  
  # =========================================================
  # 評価（お手紙）機能の関連 
  # =========================================================
  # 送信した評価 (Evaluatorとして)
  has_many :sent_evaluations, 
           class_name: 'Evaluation', 
           foreign_key: 'evaluator_id', 
           dependent: :destroy
           
  # 受け取った評価 (EvaluatedUserとして)
  has_many :received_evaluations, 
           class_name: 'Evaluation', 
           foreign_key: 'evaluated_id', 
           dependent: :destroy

  # =========================================================
  # フォロー機能
  # =========================================================
  # フォローしているユーザーへの関連 (自分がFollower)
  has_many :active_relationships, 
           class_name:  "Relationship", 
           foreign_key: "follower_id", 
           dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed

  # フォローされているユーザーへの関連 (自分がFollowed)
  has_many :passive_relationships, 
           class_name:  "Relationship", 
           foreign_key: "followed_id", 
           dependent:   :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  # =========================================================
  # Heartory Home 機能
  # =========================================================
  # 感情ログ (EmotionLog) の関連付け
  has_many :emotion_logs, dependent: :destroy
  
  # =========================================================
  # バリデーションとヘルパーメソッド
  # =========================================================
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }

  # 特定のユーザーをフォローしているか確認する
  def following?(other_user)
    following.include?(other_user)
  end
end
