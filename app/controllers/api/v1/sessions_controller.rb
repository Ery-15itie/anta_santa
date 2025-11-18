class Api::V1::SessionsController < Devise::SessionsController
  # ログアウト(destroy)時は、ユーザーがサインインしていない状態でも動作させるため、 Deviseのデフォルトのチェックをスキップ
  skip_before_action :verify_signed_out_user, only: :destroy
  
  # POST /api/v1/auth/sign_in (ログイン成功時のレスポンスをカスタマイズ)
  def respond_with(resource, _opts = {})
    # ログイン成功時、Devise-JWTが自動的にJWTトークンをHTTPヘッダーに付与
    render json: {
      status: { 
        code: 200, 
        message: 'ログインに成功しました。',
      },
      # ユーザー情報はシリアライザを使って整形 (UserSerializerは後ほど作成)
      data: {
        user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }
    }, status: :ok
  end

  # DELETE /api/v1/auth/sign_out (ログアウト時のレスポンスをカスタマイズ)
  def respond_to_on_destroy
    # Devise::JWTの RevocationStrategy がトークンを失効（Denylistに登録）させる
    if current_user.present? || request.headers['Authorization'].present?
      render json: {
        status: 200,
        message: 'ログアウトに成功しました。JWTトークンは失効されました。'
      }, status: :ok
    else
      # そもそもトークンが存在しなかった場合（認証ヘッダーがない、または無効）
      render json: {
        status: 401,
        message: 'ログアウトできませんでした。トークンが無効または見つかりません。'
      }, status: :unauthorized
    end
  end
end
