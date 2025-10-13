class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    
    begin
      # 受け取った評価
      @received_evaluations = @user.evaluations_received
                                    .includes(:evaluator, :evaluation_scores)
                                    .order(created_at: :desc)
                                    .limit(10)
      
      # 統計情報
      @total_received = @user.evaluations_received.count
      @total_given = @user.evaluations_given.count
      
      # チェックされた項目の総数
      @total_checked_items = @user.evaluations_received
                                  .joins(:evaluation_scores)
                                  .where(evaluation_scores: { score: 1 })
                                  .count
      
      # 補足: @user.evaluations_received は Evaluationモデルのhas_many :evaluations_receivedで定義されていると想定
      #       その場合、Userモデルに以下が定義されていることを前提としています:
      #       has_many :evaluations_received, class_name: 'Evaluation', foreign_key: 'evaluated_user_id'
      #       has_many :evaluations_given, class_name: 'Evaluation', foreign_key: 'evaluator_id'

    rescue => e
      # エラーログ出力
      Rails.logger.error "Dashboard Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # エラーが発生した場合、画面表示用にデフォルト値を設定
      @received_evaluations = []
      @total_received = 0
      @total_given = 0
      @total_checked_items = 0
    end
  end
end
