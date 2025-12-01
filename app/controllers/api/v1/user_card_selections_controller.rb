module Api
  module V1
    class UserCardSelectionsController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: current_user.user_card_selections
      end

      def create
        selection = current_user.user_card_selections.find_or_initialize_by(
          value_card_id: params[:value_card_id],
          timeframe: params[:timeframe]
        )
        
        # 振り返りコメントがあれば更新
        if params[:description].present?
          selection.description = params[:description]
        end

        if selection.save
          render json: selection
        else
          render json: { error: selection.errors.full_messages }, status: 422
        end
      end

      def destroy
        selection = current_user.user_card_selections.find_by(
          value_card_id: params[:id],
          timeframe: params[:timeframe]
        )
        selection&.destroy
        head :no_content
      end
    end
  end
end
