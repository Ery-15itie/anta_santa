require 'devise/orm/active_record'

Devise.setup do |config|
  # メーラー設定
  config.mailer_sender = 'admin@antasantaapp.com'

  # OmniAuth GitHub設定
  config.omniauth :github,
                  ENV['GITHUB_KEY'],
                  ENV['GITHUB_SECRET'],
                  scope: 'user:email,read:user'

  # 認証設定
  config.password_length = 6..128
  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # セッション設定
  config.remember_for = 2.weeks
  config.timeout_in = 30.minutes
  config.sign_out_all_scopes = true
  config.sign_out_via = :delete

  # パスワードリセット設定
  config.reset_password_within = 30.minutes
  config.sign_in_after_reset_password = true

  # ナビゲーション設定
  config.navigational_formats = ['*/*', :html, :turbo_stream]

  # 'Devise::CustomFailure' が未定義のため、このブロック全体をコメントアウト
  # config.warden do |manager|
  #   manager.failure_app = Devise::CustomFailure
  # end

  # 親コントローラー
  config.parent_controller = 'ApplicationController'

  # パスワードの暗号化
  config.stretches = Rails.env.test? ? 1 : 12

  # 確認メール機能（使用する場合）
  # config.reconfirmable = true
  # config.confirm_within = 3.days
  
  # =========================================================
  # JWT Token Configuration (API Authentication) 
  # devise-jwtの初期化に必要な設定です
  # =========================================================
  config.jwt do |jwt|
    # JWTの署名に使う秘密鍵を設定 (Railsの環境変数から取得)
    jwt.secret = Rails.application.credentials.secret_key_base
    
    # トークンを生成するリクエストの定義 (ログイン時)
    jwt.dispatch_requests = [
      ['POST', %r{^/users/sign_in$}],
    ]
    
    # トークン有効期間 
    jwt.expiration_time = 7.days.to_i 
    
    # トークンを無効化するリクエストの定義 (ログアウト時)
    jwt.revocation_requests = [
      ['DELETE', %r{^/users/sign_out$}],
    ]
  end
  # =========================================================
end
