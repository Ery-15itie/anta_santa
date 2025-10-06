class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  # GitHub認証プロファイルとの関連付け
  has_one :github_profile, dependent: :destroy

  # フォロー/フォロワー機能
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  # OmniAuthで使用する name と github_username
  validates :name, presence: true
  validates :github_username, presence: true, uniqueness: true

  # ユーザーのデフォルト名を設定する (GitHubから取得できない場合など)
  before_validation :set_default_name, on: :create

  # GitHub認証からユーザーを作成/検索するメソッド 
  def self.from_omniauth(auth)
    # providerとuidで既存ユーザーを検索
    user = where(provider: auth.provider, uid: auth.uid).first

    # ユーザーが存在すればそのまま返す
    return user if user.present?

    # ユーザーが存在しない場合、新規作成
    where(email: auth.info.email).first_or_create do |new_user|
      new_user.email = auth.info.email
      new_user.password = Devise.friendly_token[0, 20] # ランダムなパスワードを設定
      new_user.name = auth.info.name || auth.info.nickname # GitHubのユーザー名を使用
      new_user.github_username = auth.info.nickname || auth.info.name # GitHubのニックネームを使用
      new_user.provider = auth.provider
      new_user.uid = auth.uid
    end
  end

  private

  def set_default_name
    self.name ||= self.email.split('@').first
    self.github_username ||= self.email.split('@').first # フォールバック
  end
end
