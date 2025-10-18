class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    
    begin
      # 受け取った評価 (最新10件)
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

      # 評価された項目トップ3の集計
      @top_scores = EvaluationScore.joins(:evaluation)
                                   .joins(:template_item)
                                   .where(evaluations: { evaluated_user_id: @user.id })
                                   .where(score: 1)
                                   .group('template_items.title') # 項目タイトルでグループ化
                                   .order('count_all DESC')       # 多い順に並び替え
                                   .limit(3)                      # トップ3に絞る
                                   .count
      
      # 最近評価してくれたユーザー
      @recent_evaluators = @received_evaluations.map(&:evaluator).uniq.take(5)
      
    # indexアクション全体の rescue ブロック (例外処理)
    rescue => e
      Rails.logger.error "Dashboard Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # エラーが発生した場合、画面表示用にデフォルト値を設定
      @received_evaluations = []
      @total_received = 0
      @total_given = 0
      @total_checked_items = 0
      @top_scores = {} # トップスコアも空のハッシュに
      @recent_evaluators = [] # 最近の評価者も空の配列に
    end
  end
end
