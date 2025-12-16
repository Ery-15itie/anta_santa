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
  # 公開ID (Public ID) 設定  
  # =========================================================
  # URLや検索に使うためのID。英数字とアンダースコアのみ許可
  validates :public_id, presence: true, 
            uniqueness: { case_sensitive: false }, # ← ★ここが重要です！
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "は半角英数字とアンダースコア(_)のみ使用できます" },
            length: { minimum: 4, maximum: 20 }

  # 新規作成時に自動でIDを生成する
  before_validation :set_default_public_id, on: :create

  # =========================================================
  # その他のバリデーション
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
  def emotion_streak
    # 1. ログの日付リストを取得
    log_dates = emotion_logs.order(created_at: :desc)
                            .pluck(:created_at)
                            .map { |time| time.in_time_zone.to_date }
                            .uniq

    return 0 if log_dates.empty?

    # 2. ストリークが「現役」かチェック
    latest_date = log_dates.first
    return 0 if latest_date < Date.yesterday

    # 3. 連続日数をカウント
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
  
  # 管理者が実行するメソッド
  def generate_rescue_code!
    # 視認性の悪い文字(I, l, 1, O, 0)を除いた8桁の英数字
    chars = [('A'..'H').to_a, ('J'..'N').to_a, ('P'..'Z').to_a, ('2'..'9').to_a].flatten
    code = (0...8).map { chars[rand(chars.length)] }.join
    
    update!(
      rescue_code: code,
      rescue_code_expires_at: 24.hours.from_now
    )
    code # 管理画面(コンソール)に表示するために返す
  end

  # コード検証 & ユーザー特定
  def self.authenticate_with_rescue_code(code)
    return nil if code.blank?
    
    # 大文字小文字を無視して検索
    user = where("UPPER(rescue_code) = ?", code.upcase)
           .where("rescue_code_expires_at > ?", Time.current)
           .first
           
    if user
      # セキュリティのため即座に無効化（ワンタイム）
      user.update!(rescue_code: nil, rescue_code_expires_at: nil)
      return user
    end
    nil
  end

 # =========================================================
  # 🔗 Google連携機能
  # =========================================================
  
  # コントローラーから呼ばれる検索用メソッド
  # 既存ユーザーがいればログイン、いなければ新規登録(自動作成)
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      
      # パスワードは必須なので、安全なランダム文字列を生成
      user.password = Devise.friendly_token[0, 20]
      user.password_confirmation = user.password # 確認用にも同じ値をセット

      # 名前(Username)の設定
      # Googleの名前があればそれ、なければメアドの@より前を使う
      user.username = auth.info.name || auth.info.email.split('@')[0]
      
      # 公開ID(Public ID)の自動生成
      # 必須項目かつ重複NGなので、ランダムな文字列で生成します
      user.public_id = "user_#{SecureRandom.alphanumeric(8).downcase}"
      
      # ※画像URLを保存するカラム(image_url)設定したら以下を有効化
      # user.image_url = auth.info.image
    end
  end

  # 既存ユーザーにGoogle情報を紐付ける
  def link_google_account(auth_hash)
    # 重複チェック
    if User.exists?(provider: 'google_oauth2', uid: auth_hash[:uid])
      errors.add(:base, "このGoogleアカウントは既に他のユーザーに使用されています")
      return false
    end

    update(
      provider: 'google_oauth2',
      uid: auth_hash[:uid]
    )
  end

  private

  # =========================================================
  # 非公開メソッド (Callbacks) 
  # =========================================================
  def set_default_public_id
    # public_id が空の場合のみ生成
    return if public_id.present?

    # ランダムな8文字のIDを生成 (例: user_a1b2)
    # 重複していたら作り直すループ処理
    loop do
      self.public_id = "user_#{SecureRandom.alphanumeric(8).downcase}"
      break unless User.exists?(public_id: public_id)
    end
  end
end
