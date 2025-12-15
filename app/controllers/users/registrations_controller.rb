class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    # ▼▼▼ ログ出力▼▼▼
    Rails.logger.info "========== PASSWORD DEBUG =========="
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Password present?: #{params[:password].present?}"
    Rails.logger.info "===================================="

    # 文字列キーとシンボルキーの両方に対応できるように修正
    password = params[:password].presence || params['password'].presence
    password_conf = params[:password_confirmation].presence || params['password_confirmation'].presence

    if password || password_conf
      # パスワード変更がある場合（現在のパスワード必須）
      resource.update_with_password(params)
    else
      # パスワード変更がない場合（現在のパスワード不要）
      params.delete(:current_password)
      params.delete('current_password')
      resource.update_without_password(params)
    end
  end
  
  def after_update_path_for(resource)
    edit_user_registration_path 
  end
end
