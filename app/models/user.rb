class User < ApplicationRecord
  # Devise modules
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # -------------------------------------------------------------------------
  # フォロー機能のための関連付け
  # -------------------------------------------------------------------------

  # フォロー（自分がフォローしている関係）
  # relationship.follower が自分
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  # followed は自分がフォローしているユーザー（Relationship経由）
  has_many :following, through: :active_relationships, source: :followed

  # フォロワー（自分をフォローしている関係）
  # relationship.followed が自分
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  # followers は自分をフォローしているユーザー（Relationship経由）
  has_many :followers, through: :passive_relationships, source: :follower


  # フォロー機能のヘルパーメソッド
  # ユーザーをフォローする
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # ユーザーのフォローを解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id)&.destroy
  end

  # 現在のユーザーが他のユーザーをフォローしていれば true を返す
  def following?(other_user)
    following.include?(other_user)
  end

  # -------------------------------------------------------------------------
  # 評価（お手紙）機能のための関連付け
  # Evaluationモデルのフィールド名に合わせる
  # -------------------------------------------------------------------------

  # もらったお手紙（自分が evaluated_user 側）
  has_many :received_evaluations, class_name: "Evaluation",
                                  foreign_key: "evaluated_user_id", # ターゲットの外部キー
                                  dependent: :destroy

  # 送ったお手紙（自分が evaluator 側）
  has_many :sent_evaluations, class_name: "Evaluation",
                              foreign_key: "evaluator_id", # ターゲットの外部キー
                              dependent: :destroy


  # -------------------------------------------------------------------------
  # バリデーションなど
  # -------------------------------------------------------------------------

  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }
end
