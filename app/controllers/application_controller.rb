class ApplicationController < ActionController::Base
  # Deviseコントローラーで利用するためにカスタムセッションロジックを追加
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Deviseのパラメーターを許可する（username, image_urlの追加を許可）
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :image_url])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :image_url])
  end
              
  # ログイン後のリダイレクト先
  # 新しいダッシュボード（HomesController#index）は root_path に設定されているため、ここを root_path にすることで、ログイン後すぐに10部屋の画面に行ける
  def after_sign_in_path_for(resource)
    root_path
  end

  # ログアウト後のリダイレクト先
  # ログイン画面（new_user_session_path）に戻します
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
