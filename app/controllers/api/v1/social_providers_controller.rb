module Api
  module V1
    class SocialProvidersController < ApplicationController
      before_action :authenticate_user!

      # DELETE /api/v1/social_provider
      # Google連携を解除する
      def destroy
        # providerとuidをnilにして連携を切る
        if current_user.update(provider: nil, uid: nil)
          render json: { 
            message: "Google連携を解除しました",
            is_google_linked: false 
          }, status: :ok
        else
          render json: { error: "解除に失敗しました" }, status: :unprocessable_entity
        end
      end
    end
  end
end
