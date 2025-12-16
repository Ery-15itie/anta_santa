module Api
  module V1
    class RescueSessionsController < ApplicationController
      # APIとして外部から叩けるように、CSRFセキュリティチェックを無効化
      skip_before_action :verify_authenticity_token

      # "authenticate_user!" が親コントローラーになくてもエラーにしない
      skip_before_action :authenticate_user!, raise: false

      def create
        # 1. 送られてきたコードでユーザーを探す
        user = User.authenticate_with_rescue_code(params[:code])

        if user
          # 【重要】サーバー側でログイン処理を実行
          # これにより、レスポンスヘッダーに「ログイン用Cookie」がセット
          # 次の画面遷移（リダイレクト）後もログイン状態が維持
          sign_in(user)

          # セキュリティのため、使用済みの救済コードを無効化
          user.update(rescue_code: nil, rescue_code_expires_at: nil)

          # 2. クライアント(React)に成功メッセージと移動先URLを返す
          render json: {
            message: "本人確認が完了しました。プロフィール設定へ移動します。",
            # フロントエンド側でこのURLに window.location.href してもらう
            redirect_url: edit_user_registration_path 
          }, status: :ok
        else
          # 認証失敗
          render json: { error: "コードが無効、または期限切れです。" }, status: :unauthorized
        end
      end
    end
  end
end
