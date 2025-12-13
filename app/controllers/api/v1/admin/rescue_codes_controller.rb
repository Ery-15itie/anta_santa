module Api
  module V1
    module Admin
      class RescueCodesController < ApplicationController
        before_action :authenticate_user!
        before_action :require_admin!

        def create
          target_user = find_target_user
          
          if target_user
            code = target_user.generate_rescue_code!
            render json: { 
              message: "救済コードを発行しました", 
              username: target_user.username,
              rescue_code: code 
            }, status: :ok
          else
            render json: { error: "ユーザーが見つかりませんでした" }, status: :not_found
          end
        end

        private

        def find_target_user
          if params[:username].present?
            User.find_by(username: params[:username])
          elsif params[:user_id].present?
            User.find_by(id: params[:user_id])
          end
        end

        def require_admin!
          # 環境変数から読み込む
          # 設定されていなければ安全のため nil になり、誰とも一致しません
          admin_email = ENV['ADMIN_EMAIL']

          # admin_email が存在し、かつログインユーザーのメアドと一致するか
          unless admin_email.present? && current_user.email == admin_email
            render json: { error: "管理者権限がありません" }, status: :forbidden
          end
        end
      end
    end
  end
end
