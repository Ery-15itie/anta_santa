module Api
  module V1
    class RescueSessionsController < ApplicationController
      # APIとして外部から叩けるように、CSRFセキュリティチェックを無効化
      skip_before_action :verify_authenticity_token

      # "authenticate_user!" が親コントローラーになくてもエラーにしない
      skip_before_action :authenticate_user!, raise: false

      def create
        # 送られてきたコードでユーザーを探す
        user = User.authenticate_with_rescue_code(params[:code])

        if user
          # 救済成功！JWTトークンを手動生成
          token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

          render json: {
            message: "本人確認完了。設定画面より新しいパスワードを設定してください。",
            token: token,
            user: {
              id: user.id,
              username: user.username,
              email: user.email
            }
          }, status: :ok
        else
          render json: { error: "コードが無効、または期限切れです。" }, status: :unauthorized
        end
      end
    end
  end
end
