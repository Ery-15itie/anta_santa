class Api::V1::RegistrationsController < Devise::RegistrationsController
  # POST /api/v1/auth (ユーザー登録成功/失敗時のレスポンスをカスタマイズ)
  def respond_with(resource, _opts = {})
    if resource.persisted?
      # 登録成功時
      render json: {
        status: { 
          code: 200, 
          message: 'ユーザー登録に成功しました。',
        },
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }
      }, status: :ok
    else
      # 登録失敗時（バリデーションエラーなど）
      render json: {
        status: { 
          code: 422, 
          # エラーメッセージを連結してクライアントに返す
          message: "ユーザー登録に失敗しました: #{resource.errors.full_messages.to_sentence}"
        }
      }, status: :unprocessable_entity
    end
  end
end
