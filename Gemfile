source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Railsのバージョン指定
gem "rails", "~> 7.2.2" 

# データベース
gem 'mysql2', '~> 0.5.5' # MySQL/MariaDB用
gem 'pg', '~> 1.5' # PostgreSQL用

# Webサーバー
gem "puma", "~> 6.0"

# JavaScriptとCSSバンドル（Docker環境では必須）
gem 'sprockets-rails', '~> 3.2' # Asset Pipeline
gem "sass-rails", ">= 6" # SASS/SCSSを有効化
gem "importmap-rails"

# Hotwire (Turbo and Stimulus)
gem "turbo-rails"
gem "stimulus-rails"

# UI・グラフ
gem 'bootstrap', '~> 5.3'
gem 'chartkick'
gem 'groupdate'

# PDF生成
gem 'prawn'
gem 'prawn-table'

# 認証・認可
gem 'devise'
gem 'omniauth'
gem 'omniauth-github', '~> 2.0'
gem 'omniauth-rails_csrf_protection'

# GitHub API
gem 'octokit', '~> 4.0'

# Faraday関連 (GitHub API通信用・必須)
gem 'faraday-retry'

# バックグラウンドジョブ
gem 'sidekiq'
gem 'redis', '~> 4.0'

# 国際化
gem 'rails-i18n'

# 画像処理
gem "image_processing", "~> 1.12"

# タイムゾーンデータ (Windows環境用)
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# ブートタイム短縮
gem "bootsnap", require: false

# 開発・テスト環境
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'pry-rails' # デバッグ用
  gem 'pry-byebug' # ブレークポイント
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate' # モデルにスキーマ情報を自動記載
  gem 'bullet' # N+1クエリ検出
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
end

gem "tailwindcss-rails", "~> 3"
