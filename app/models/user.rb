class User < ApplicationRecord
  # =========================================================
  # 認証機能 (Devise & JWT)
  # =========================================================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, 
         :omniauthable, 
         jwt_revocation_strategy: JwtDenylist,
         omniauth_providers: %i[github google_oauth2]

  # =========================================================
  # アソシエーション (関連付け)
  # =========================================================
  # GitHub連携プロフィール (コントローラーでの保存処理に必要)
  has_one :github_profile, dependent: :destroy

  # 評価（お手紙）機能
  has_many :sent_evaluations, class_name: 'Evaluation', foreign_key: 'evaluator_id', dependent: :destroy
  has_many :received_evaluations, class_name: 'Evaluation', foreign_key: 'evaluated_user_id', dependent: :destroy

  # フォロー機能
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  # Heartory Home 機能
  has_many :emotion_logs, dependent: :destroy

  # サンタの書斎 (価値観パズル) 機能
  has_many :user_card_selections, dependent: :destroy
  has_many :selected_value_cards, through: :user_card_selections, source: :value_card

  # 心の航海日誌 (Magic Book) 機能 
  has_many :user_reflections, dependent: :destroy

  # =========================================================
  # 公開ID (Public ID) 設定  
  # =========================================================
  validates :public_id, presence: true, 
            uniqueness: { case_sensitive: false }, 
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "は半角英数字とアンダースコア(_)のみ使用できます" },
            length: { minimum: 4, maximum: 20 }

  # 新規作成時に自動でIDを生成
  before_validation :set_default_public_id, on: :create

  # =========================================================
  # その他のバリデーション
  # =========================================================
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }

  # =========================================================
  # ヘルパーメソッド (ロジック判定用)
  # =========================================================
  def following?(other_user)
    following.include?(other_user)
  end

  # =========================================================
  # 統計・集計ロジック
  # =========================================================
  def emotion_streak
    log_dates = emotion_logs.order(created_at: :desc)
                            .pluck(:created_at)
                            .map { |time| time.in_time_zone.to_date }
                            .uniq

    return 0 if log_dates.empty?
    latest_date = log_dates.first
    return 0 if latest_date < Date.yesterday

    streak = 0
    check_date = latest_date
    log_dates.each do |date|
      if date == check_date
        streak += 1
        check_date -= 1.day 
      else
        break
      end
    end
    streak
  end

  # =========================================================
  # 🚑 管理者用救済機能 (Rescue Code)
  # =========================================================
  def generate_rescue_code!
    chars = [('A'..'H').to_a, ('J'..'N').to_a, ('P'..'Z').to_a, ('2'..'9').to_a].flatten
    code = (0...8).map { chars[rand(chars.length)] }.join
    update!(rescue_code: code, rescue_code_expires_at: 24.hours.from_now)
    code
  end

  def self.authenticate_with_rescue_code(code)
    return nil if code.blank?
    user = where("UPPER(rescue_code) = ?", code.upcase)
           .where("rescue_code_expires_at > ?", Time.current)
           .first
    if user
      user.update!(rescue_code: nil, rescue_code_expires_at: nil)
      return user
    end
    nil
  end

  # =========================================================
  # 🔗 Google連携機能
  # =========================================================
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.password_confirmation = user.password 
      user.username = auth.info.name || auth.info.email.split('@')[0]
      user.public_id = "user_#{SecureRandom.alphanumeric(8).downcase}"
    end
  end

  def link_google_account(auth_hash)
    if User.exists?(provider: 'google_oauth2', uid: auth_hash[:uid])
      errors.add(:base, "このGoogleアカウントは既に他のユーザーに使用されています")
      return false
    end
    update(provider: 'google_oauth2', uid: auth_hash[:uid])
  end

  private

  def set_default_public_id
    return if public_id.present?
    loop do
      self.public_id = "user_#{SecureRandom.alphanumeric(8).downcase}"
      break unless User.exists?(public_id: public_id)
    end
  end
end
