require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SantaReportApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    
    # タイムゾーンを日本時間に設定
    config.time_zone = "Tokyo"
    # データベースから読み出す時刻も東京時間に合わせる
    config.active_record.default_timezone = :local

    # アプリケーションのデフォルト言語を日本語に設定
    config.i18n.default_locale = :ja
    # config/locales配下のYAMLファイルをすべて読み込む
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    
    # autoloadingをroutes.rbの前に強制し、Deviseエラーを解決
    # この行により、Userモデルがroutes.rbより早くロードされる
    config.eager_load_paths << Rails.root.join("app", "models")

    # セッション設定（CSRF対策）
    config.session_store :cookie_store, key: "_santa_report_session", expire_after: 1.day

    # config.eager_load_paths << Rails.root.join("extras") 

    # 以前のbefore_configurationブロックコメントアウト
    # config.before_configuration do
    #   require_relative '../../app/models/user' if File.exist?(Rails.root.join('app', 'models', 'user.rb'))
    # end
  end
end
