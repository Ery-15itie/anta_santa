# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# ---------------------------------------------------------------------
# ailwind CSS x SassC エラー回避設定
# ---------------------------------------------------------------------
# Tailwind CSSの新しい構文(rgb関数など)をSassCがエラーとして扱ってしまうのを防ぐため、CSSの圧縮機能を無効化
Rails.application.config.assets.css_compressor = nil