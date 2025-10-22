class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    
    begin
      # 受け取った評価 (ビューの変数名 @recent_received_evaluations に合わせる)
      @recent_received_evaluations = @user.evaluations_received
                                    .includes(:evaluator, :evaluation_scores)
                                    .order(created_at: :desc)
                                    .limit(10)
      
      # 送信した評価 
      @recent_sent_evaluations = @user.evaluations_given
                                      .order(created_at: :desc)
                                      .limit(5)
      
      # 統計情報
      @total_received = @user.evaluations_received.count
      @total_given = @user.evaluations_given.count
      
      # チェックされた項目の総数
      @total_checked_items = @user.evaluations_received
                                  .joins(:evaluation_scores)
                                  .where(evaluation_scores: { score: 1 })
                                  .count

      # 評価された項目トップ3の集計
      @top_scores = EvaluationScore.joins(:evaluation)
                                   .joins(:template_item)
                                   .where(evaluations: { recipient_id: @user.id }) # recipient_idに修正
                                   .where(score: 1)
                                   .group('template_items.title')
                                   .order('count_all DESC')
                                   .limit(3)
                                   .count
      
      # 最近評価してくれたユーザー
      @recent_evaluators = @recent_received_evaluations.map(&:evaluator).uniq.take(5)
      
    # indexアクション全体の rescue ブロック (例外処理)
    rescue => e
      Rails.logger.error "Dashboard Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # エラーが発生した場合、画面表示用にデフォルト値を設定
      @recent_received_evaluations = [] # ビューで使われる変数名をクリア
      @recent_sent_evaluations = []     # ビューで使われる変数名をクリア
      @total_received = 0
      @total_given = 0
      @total_checked_items = 0
      @top_scores = {}
      @recent_evaluators = []
    end
  end
end
