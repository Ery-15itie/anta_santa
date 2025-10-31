class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
           foreign_key: 'evaluated_user_id', 
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
  # バリデーションとヘルパーメソッド
  # =========================================================
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }

  # 特定のユーザーをフォローしているか確認する
  def following?(other_user)
    following.include?(other_user)
  end
end
