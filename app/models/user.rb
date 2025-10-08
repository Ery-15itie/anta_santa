class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  # Associations
  has_one :github_profile, dependent: :destroy
  
  # フォロー機能
  has_many :active_relationships, class_name: 'Relationship',
                                   foreign_key: 'follower_id',
                                   dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship',
                                    foreign_key: 'followed_id',
                                    dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  
  # テンプレート
  has_many :templates, dependent: :destroy
  
  # 評価
  has_many :evaluations_given, class_name: 'Evaluation',
                                foreign_key: 'evaluator_id',
                                dependent: :destroy
  has_many :evaluations_received, class_name: 'Evaluation',
                                   foreign_key: 'evaluated_user_id',
                                   dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 50 }
  validates :provider, presence: true, if: :uid?
  validates :uid, presence: true, if: :provider?
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true

  # OmniAuth callback用クラスメソッド
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name || auth.info.nickname
      user.image_url = auth.info.image
      user.github_username = auth.info.nickname
    end
  end

  # Instance methods
  def display_name
    name.presence || github_username.presence || email.split('@').first
  end

  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
