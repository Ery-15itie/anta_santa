class ApplicationController < ActionController::Base
  # Deviseコントローラーで利用するためにカスタムセッションロジックを追加
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Deviseのパラメーターを許可する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :public_id, :image_url])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :public_id, :image_url])
  end
              
  # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource)
    root_path
  end

  # ログアウト後のリダイレクト先
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
