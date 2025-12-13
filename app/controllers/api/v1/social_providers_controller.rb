module Api
  module V1
    class SocialProvidersController < ApplicationController
      # ログイン必須
      before_action :authenticate_user! 

      def create
        auth_data = { uid: params[:uid] }

        if current_user.link_google_account(auth_data)
          render json: { message: "Googleアカウントと連携しました！" }, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if current_user.update(provider: nil, uid: nil)
          render json: { message: "Google連携を解除しました" }, status: :ok
        else
          render json: { errors: "解除に失敗しました" }, status: :unprocessable_entity
        end
      end
    end
  end
end
