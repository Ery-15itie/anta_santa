# config/initializers/devise.rb
require 'devise/orm/active_record'

Devise.setup do |config|
  # =========================================================
  # メーラー設定
  # =========================================================
  config.mailer_sender = 'admin@antasantaapp.com'

  # =========================================================
  # OmniAuth 設定 (SNS連携)
  # =========================================================
  
  # 1. Google (今回のメイン: 引継ぎ・連携用)
  config.omniauth :google_oauth2,
                  ENV['GOOGLE_CLIENT_ID'],
                  ENV['GOOGLE_CLIENT_SECRET'],
                  {
                    scope: 'email,profile',
                    prompt: 'select_account',
                    image_aspect_ratio: 'square',
                    image_size: 50
                  }

  # 2. GitHub (既存の設定: .envに合わせて変数名を修正済み)
  config.omniauth :github,
                  ENV['GITHUB_CLIENT_ID'],     
                  ENV['GITHUB_CLIENT_SECRET'], 
                  scope: 'user:email,read:user'

  # =========================================================
  # 認証設定
  # =========================================================
  config.password_length = 6..128
  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # =========================================================
  # セッション・セキュリティ設定
  # =========================================================
  config.remember_for = 2.weeks
  config.timeout_in = 30.minutes
  config.sign_out_all_scopes = true
  config.sign_out_via = :delete

  # パスワードリセット設定
  config.reset_password_within = 30.minutes
  config.sign_in_after_reset_password = true

  # ナビゲーション設定
  config.navigational_formats = ['*/*', :html, :turbo_stream]

  # 親コントローラー
  config.parent_controller = 'ApplicationController'

  # パスワードの暗号化強度
  config.stretches = Rails.env.test? ? 1 : 12

  # =========================================================
  # JWT Token Configuration (API Authentication) 
  # devise-jwtの初期化設定
  # =========================================================
  config.jwt do |jwt|
    # JWTの署名に使う秘密鍵 (Railsのcredentialsまたは環境変数)
    jwt.secret = Rails.application.credentials.secret_key_base
    
    # トークンを生成するリクエスト (ログイン時)
    jwt.dispatch_requests = [
      ['POST', %r{^/users/sign_in$}],
      # 必要に応じて救済コード用のAPIも含めることができますが、
      # 現状の実装(Warden::JWTAuth::UserEncoderを手動呼び出し)ならこのままでOKです
    ]
    
    # トークン有効期間 (7日間)
    jwt.expiration_time = 7.days.to_i 
    
    # トークンを無効化するリクエスト (ログアウト時)
    jwt.revocation_requests = [
      ['DELETE', %r{^/users/sign_out$}],
    ]
  end
end
