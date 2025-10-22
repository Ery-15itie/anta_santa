class ApplicationController < ActionController::Base
  # Deviseコントローラーで利用するためにカスタムセッションロジックを追加
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Deviseのパラメーターを許可する（usernameの追加を許可）
  def configure_permitted_parameters
    # sign_up 時に username, image_url を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :image_url])
    # account_update 時に username, image_url を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :image_url])
  end
              
  # ログイン後のリダイレクト先をダッシュボードに変更
  def after_sign_in_path_for(resource)
    dashboard_path # 新しいルーティングヘルパーを使用
  end

  # ログアウト後のリダイレクト先をトップページ（ログイン画面）に変更
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
