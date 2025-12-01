module Api
  module V1
    class ValueCategoriesController < ApplicationController
      def index
        # カテゴリーとカードをまとめて取得
        categories = ValueCategory.includes(:value_cards).all
        
        # JSON形式で返す
        render json: categories.as_json(
          only: [:id, :name, :theme_color, :icon_key],
          include: { 
            value_cards: { only: [:id, :name, :description] } 
          }
        )
      end
    end
  end
end
