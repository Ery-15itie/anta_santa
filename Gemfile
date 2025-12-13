source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Railsのバージョン指定
gem "rails", "~> 7.2.2" 

# データベース
gem 'pg', "~> 1.5" # PostgreSQL用

# Webサーバー
gem "puma", "~> 6.0"

# ---------------------------------------------------
# ▼ React / Frontend 関連
# ---------------------------------------------------
# Asset Pipeline (画像やCSSの管理)
gem 'sprockets-rails', "~> 3.2"

# SASS/SCSS (CSSの拡張)
gem "sass-rails", ">= 6"

# Importmap (既存のJS用)
gem "importmap-rails"

# Reactのビルドに必須 (esbuildを使用)
gem "jsbundling-rails"

# Hotwire (Turbo and Stimulus)
gem "turbo-rails"
gem "stimulus-rails"

# UI・グラフ
gem 'bootstrap', "~> 5.3"
gem 'chartkick'
gem 'groupdate'

# ---------------------------------------------------
# ▼ 認証・認可・API 関連 
# ---------------------------------------------------
gem 'devise'

# JWT認証 (API連携・モバイルアプリ連携用)
gem 'devise-jwt', "~> 0.12.1"

# OmniAuth (SNS連携基盤)
gem 'omniauth'
gem 'omniauth-rails_csrf_protection' # Railsセキュリティ対策（必須）

# SNSプロバイダー
gem 'omniauth-google-oauth2'         # ★今回追加: Google連携・引継ぎ用
gem 'omniauth-github', "~> 2.0"      # 既存: GitHub連携 (Octokit等で使用するため維持)

# ---------------------------------------------------
# ▼ 外部API・ジョブ・ユーティリティ
# ---------------------------------------------------
# GitHub API操作用 (Repo情報取得など)
gem 'octokit', "~> 4.0"

# PDF生成
gem 'prawn'
gem 'prawn-table'

# HTTPクライアント
gem 'faraday-retry'

# バックグラウンドジョブ
gem 'sidekiq'
gem 'redis', "~> 4.0"

# 国際化
gem 'rails-i18n'

# 画像処理
gem "image_processing", "~> 1.12"

# タイムゾーンデータ
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# ブートタイム短縮
gem "bootsnap", require: false

# ---------------------------------------------------
# ▼ 開発・テスト環境
# ---------------------------------------------------
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', "~> 6.0"
  gem 'factory_bot_rails', "~> 6.2"
  gem 'faker', "~> 3.2"
  gem 'pry-rails'
  gem 'pry-byebug'

  # ★推奨追加: 環境変数管理 (.envファイル用)
  # Google Client ID等をローカルで管理するのに必須
  gem 'dotenv-rails' 
end

group :development do
  gem 'web-console', ">= 4.1.0"
  gem 'listen', "~> 3.3"
  gem 'spring'
  gem 'spring-watcher-listen', "~> 2.0.0"
  gem 'annotate'
  gem 'bullet'
  
  # メール確認用
  gem 'letter_opener'
  gem 'letter_opener_web'
end

group :test do
  gem 'capybara', ">= 3.26"
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', "~> 5.0"
  gem 'database_cleaner-active_record'
end
