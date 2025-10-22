Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

# 開発環境でのCSRFチェックを無効化
if Rails.env.development?
  OmniAuth.config.test_mode = false
  OmniAuth.config.allowed_request_methods = [:get, :post]
end
