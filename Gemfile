source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Railsのバージョン指定
gem "rails", "~> 8.0.3" 

# データベース
gem 'mysql2', '~> 0.5.5' # MySQL/MariaDB用

# Webサーバー
gem "puma", "~> 6.0"

# JavaScriptとCSSバンドル（Docker環境では必須）
gem 'sprockets-rails', '~> 3.2' # Asset Pipeline
gem "sass-rails", ">= 6" # SASS/SCSSを有効化
gem "jsbundling-rails"
gem "cssbundling-rails"

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
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'

# GitHub API
gem 'octokit', '~> 4.0'

# バックグラウンドジョブ
gem 'sidekiq'
gem 'redis', '~> 4.0'

# 国際化
gem 'rails-i18n'

# 画像処理
gem "image_processing", "~> 1.12"

# 開発・テスト環境
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end
