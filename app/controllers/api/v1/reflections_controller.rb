module Api
  module V1
    class ReflectionsController < ApplicationController
      before_action :authenticate_user!

      def index
        # 質問一覧を取得
        questions = ReflectionQuestion.order(:position).all
        
        # 質問と、ユーザーの保存済み回答を結合して返す
        data = questions.map do |q|
          answer = current_user.user_reflections.find_by(reflection_question_id: q.id)
          {
            id: q.id,
            body: q.body,
            category: q.category,
            answer: answer&.answer || "" # 未回答なら空文字
          }
        end
        
        render json: data
      end

      def update
        # URLの :id を reflection_question_id として扱います
        reflection = current_user.user_reflections.find_or_initialize_by(
          reflection_question_id: params[:id]
        )
        reflection.answer = params[:answer]
        
        if reflection.save
          render json: { status: 'saved' }
        else
          render json: { error: '保存できませんでした' }, status: 422
        end
      end
    end
  end
end
