# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!

# ディレクトリ構成を整理したい場合に備えて、support配下の読み込みを有効化しておくと便利
# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # ------------------------------------------------------------
  # FactoryBot と Devise の設定
  # ------------------------------------------------------------
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request

  # ------------------------------------------------------------
  # システムスペック (ブラウザテスト) の設定
  # ------------------------------------------------------------
  # 通常のテスト（JS不要）は高速な rack_test を使用
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # JSが必要なテスト(js: true)の設定
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400] do |options|
      # ヘッドレスモード（画面を表示せずに実行）
      options.add_argument('--headless=new')
      
      # Docker環境で動作させるための必須オプション
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--disable-gpu')
      options.add_argument('--window-size=1400,1400')

      # 【重要】Docker環境(Linux)とローカル(Mac等)の両方に対応させる安全策
      # 指定されたパスにChromiumがある場合のみバイナリパスをセット
      chromium_path = "/usr/bin/chromium"
      options.binary = chromium_path if File.exist?(chromium_path)
    end
  end

  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# ------------------------------------------------------------
# Shoulda Matchers の設定 
# ------------------------------------------------------------
# これがないと validate_uniqueness_of などが使えない
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
