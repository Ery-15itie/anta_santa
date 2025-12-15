module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/profile
      def show
        render json: {
          user: {
            id: current_user.id,
            username: current_user.username,
            public_id: current_user.public_id,
            email: current_user.email,
            # Google連携済みかどうかを判定
            is_google_linked: current_user.provider == 'google_oauth2'
          }
        }, status: :ok
      end

      # PUT/PATCH /api/v1/profile
      def update
        # 「新しいパスワード」の入力があるかをチェック
        # (current_passwordがあるかではなく、変更しようとしているかで判断する)
        if profile_params[:password].present? || profile_params[:password_confirmation].present?
          
          # 【パスワード変更モード】
          # update_with_password は「現在のパスワード(current_password)」が空、または間違っているとfalseを返します
          if current_user.update_with_password(profile_params)
            # パスワード変更後もログアウトさせない（Deviseのヘルパー）
            bypass_sign_in(current_user)
            render_success("アカウント情報を更新しました")
          else
            # 現在のパスワードが違う、または空の場合はここでエラーメッセージが返ります
            render_error(current_user.errors.full_messages)
          end
        
        else
          # 【プロフィール更新モード（パスワード変更なし）】
          # current_password が送られてきても無視して削除する
          clean_params = profile_params.except(:current_password, :password, :password_confirmation)

          # パスワードなしで更新できるメソッドを使用
          if current_user.update_without_password(clean_params)
            render_success("プロフィールを更新しました")
          else
            render_error(current_user.errors.full_messages)
          end
        end
      end

      private

      def profile_params
        # userキーの中身を許可
        params.require(:user).permit(:username, :public_id, :email, :password, :password_confirmation, :current_password)
      end

      def render_success(msg)
        render json: { 
          message: msg, 
          user: {
            id: current_user.id,
            username: current_user.username,
            public_id: current_user.public_id,
            email: current_user.email,
            is_google_linked: current_user.provider == 'google_oauth2'
          }
        }, status: :ok
      end

      def render_error(errors)
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end
end
