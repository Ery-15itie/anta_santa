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
          # 2. 【重要】サーバー側でログイン状態にする
          # これによりブラウザに「ログイン済みCookie」がセットされ、画面遷移後もログイン状態が維持されます
          sign_in(user)

          # 3. セキュリティのため、使用済みの救済コードを無効化する
          user.update(rescue_code: nil, rescue_code_expires_at: nil)

          # 4. フロントエンドで使うためのJWTトークンも一応生成して返す
          # (React側で localStorage に保存している処理があるため)
          token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

          # 5. 成功メッセージと移動先URLを返す
          render json: {
            message: "本人確認が完了しました。Heartory Homeへ移動します。",
            token: token,
            # ▼▼▼ 移動先をトップページ(ルート)に設定 ▼▼▼
            redirect_url: root_path 
          }, status: :ok
        else
          # 認証失敗
          render json: { error: "コードが無効、または期限切れです。" }, status: :unauthorized
        end
      end
    end
  end
end
