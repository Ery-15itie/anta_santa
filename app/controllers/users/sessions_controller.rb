class Users::SessionsController < Devise::SessionsController
  # 末尾に , raise: false を追加
  # これにより、親クラスでCSRF対策が定義されていなくてもエラーにならない
  skip_before_action :verify_authenticity_token, only: [:create, :destroy], raise: false

  # POST /resource/sign_in (ログイン)
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    
    if request.format.json?
      # JSONリクエスト (APIログイン) 
      # 成功時はJSONレスポンスを返し、devise-jwtが自動的にJWTトークンをレスポンスヘッダーに含める
      render json: { 
        message: I18n.t('devise.sessions.signed_in'), 
        user: { id: resource.id, email: resource.email, username: resource.username }
      }, status: :ok
    else
      # HTMLリクエスト (通常のWebログイン)
      # 元のDeviseの動作（リダイレクト）を維持
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  # DELETE /resource/sign_out (ログアウト)
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    
    if request.format.json?
      # JSONリクエスト (APIログアウト) 
      # 成功時はJSONレスポンスを返し、JWTを破棄
      head :ok
    else
      # HTMLリクエスト (通常のWebログアウト)
      # 元のDeviseの動作（リダイレクト）を維持
      respond_to_on_destroy
    end
  end

  protected
  
  # 認証失敗時の処理をオーバーライド
  # HTMLとJSONで異なるレスポンスを返す
  def respond_to_on_failure
    if request.format.json?
      # API認証失敗時はJSONエラーを返す
      render json: { 
        error: I18n.t('devise.failure.invalid') # invalid は 'メールアドレスまたはパスワードが違います'
      }, status: :unauthorized
    else
      # HTML認証失敗時はDeviseのデフォルト処理
      super
    end
  end

  # HTMLリクエスト時のリダイレクト動作を維持
  def respond_with(resource, _opts = {})
    if request.format.html?
      super
    end
  end
  
  # HTMLリクエスト時のログアウトリダイレクト動作を維持
  def respond_to_on_destroy
    if request.format.html?
      respond_with_navigational(resource_name) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end
end
