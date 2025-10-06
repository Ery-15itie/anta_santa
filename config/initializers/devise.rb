# config/initializers/devise.rb

require 'devise/orm/active_record'

Devise.setup do |config|
  # メーラー設定
  config.mailer_sender = 'noreply@anta-santa.com'

  # OmniAuth GitHub設定
  config.omniauth :github,
                  ENV['GITHUB_KEY'],
                  ENV['GITHUB_SECRET'],
                  scope: 'user:email,read:user'

  # 認証設定

  # パスワードの長さ
  config.password_length = 6..128

  # サインインに使用するキー
  config.authentication_keys = [:email]

  # 大文字小文字を区別しない
  config.case_insensitive_keys = [:email]

  # 空白を削除する
  config.strip_whitespace_keys = [:email]

  # セッション設定
  # Remember me機能の有効期限
  config.remember_for = 2.weeks

  # セッションタイムアウト
  config.timeout_in = 30.minutes

  # サインアウト時に全スコープからサインアウトするか
  config.sign_out_all_scopes = true

  # サインアウトのHTTPメソッド
  config.sign_out_via = :delete

  # パスワードリセット設定
  # パスワードリセットトークンの有効期限
  config.reset_password_within = 6.hours

  # パスワード変更後に自動ログイン
  config.sign_in_after_reset_password = true

  # ロック設定（オプション）
  # config.maximum_attempts = 7
  # config.unlock_strategy = :email
  # config.lock_strategy = :failed_attempts

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
end
