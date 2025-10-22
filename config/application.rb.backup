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
    #
    # config.time_zone = "Central Time (US & Canada)"
    
    # autoloadingをroutes.rbの前に強制し、Deviseエラーを解決
    # この行により、Userモデルがroutes.rbより早くロードされる
    config.eager_load_paths << Rails.root.join("app", "models")

    # config.eager_load_paths << Rails.root.join("extras") 

    # 以前のbefore_configurationブロックコメントアウト
    # config.before_configuration do
    #   require_relative '../../app/models/user' if File.exist?(Rails.root.join('app', 'models', 'user.rb'))
    # end
  end
end
