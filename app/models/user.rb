class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # GitHub認証を一時的に無効化するため、:omniauthable は外してる
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # GitHub認証のコードは残しておき、後で簡単に復帰できるように！
  # def self.from_omniauth(auth)
  #   where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #     user.email = auth.info.email
  #     user.password = Devise.friendly_token[0, 20]
  #     user.username = auth.info.nickname || auth.info.name
  #     # ユーザーのプロフィール画像なども設定可能
  #   end
  # end

  # ユーザー名（username）は必須、一意
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }

  # ==================================
  # 評価（Evaluation）関連アソシエーション -　命名の統一チェック
  # ==================================
  # 自分が送った評価 (Evaluation モデルの :evaluator に対応)
  has_many :evaluator_evaluations, 
           class_name: 'Evaluation', 
           foreign_key: 'evaluator_id', 
           dependent: :destroy
  
  # 自分が受け取った評価 (Evaluation モデルの :evaluated_user に対応)
  has_many :evaluated_user_evaluations, 
           class_name: 'Evaluation', 
           foreign_key: 'evaluated_user_id', 
           dependent: :destroy

  # ==================================
  # フォロー（Follow）関連アソシエーション
  # ==================================
  # 自分がフォローしている人たち (Following)
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  
  # 自分をフォローしている人たち (Followers)
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  # ==================================
  # フォロー関連のカスタムメソッド
  # ==================================
  # 特定のユーザーをフォローする
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # 特定のユーザーのフォローを解除する
  def unfollow(other_user)
    following.delete(other_user)
  end

  # 特定のユーザーをフォローしているかどうかを返す
  def following?(other_user)
    following.include?(other_user)
  end
end
