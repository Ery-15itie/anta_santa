# Active RecordをDeviseが使うORMとして明示的にロードし、起動時のエラーを回避
require 'devise/orm/active_record' 

Devise.setup do |config|
  # ▼ GitHub認証の設定 ▼
  # GitHub KeyとSecretを環境変数から読み込み、GitHub認証を有効化
  config.omniauth :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email,read:user'

  # ▼ その他のDeviseの基本設定（デフォルトを有効化した状態） ▼

  # デフォルトのメーラーアドレス
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # パスワードの最小文字数
  config.password_length = 6..128

  # サインイン試行回数の制限 (最大20回失敗まで許容)
  config.maximum_attempts = 20

  # パスワードリセットトークンの有効期限 (デフォルト: 6時間)
  config.reset_password_within = 6.hours

  # データベース認証に使用するキー
  config.authentication_keys = [:email]

  # Deviseの親コントローラー
  config.parent_controller = 'ApplicationController'

  # CSRFトークンを自動で設定
  config.navigational_formats = ['*/*', :html]

  # サインイン後にすべてのスコープからサインアウトしない設定
  config.sign_out_all_scopes = false 
end
