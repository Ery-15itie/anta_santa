class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    
    begin
      # 受け取った評価 (最新10件) - User.received_evaluations を使用
      @recent_received_evaluations = @user.received_evaluations
                                    .includes(:evaluator, :evaluation_scores)
                                    .order(created_at: :desc)
                                    .limit(10)
      
      # 送信した評価 (最新5件) - User.sent_evaluations を使用
      @recent_sent_evaluations = @user.sent_evaluations
                                      .order(created_at: :desc)
                                      .limit(5)
      
      # --- 個人統計情報 ---
      
      # 1. もらったお手紙の総数
      @total_received = @user.received_evaluations.count
      
      # 2. 送ったお手紙の総数
      @total_given = @user.sent_evaluations.count
      
      # 3. チェックされた項目の総数（褒められたポイント）
      @total_checked_items = @user.received_evaluations
                                  .joins(:evaluation_scores)
                                  .where(evaluation_scores: { score: 1 })
                                  .count

      # 4. 評価された項目トップ3の集計
      # @userが受け取った評価に含まれる、score=1のEvaluationScoreをTemplateItemごとに集計
      top_score_counts = EvaluationScore.joins(:evaluation)
                                   .joins(:template_item)
                                   # @userが被評価者であるEvaluationのみを対象とする
                                   .where(evaluations: { evaluated_user_id: @user.id }) 
                                   .where(score: 1)
                                   .group('template_items.title', 'template_items.category')
                                   .order('count_all DESC')
                                   .limit(3)
                                   .count
      
      # ビューでの表示用に、{タイトル, カテゴリー, カウント} の配列に変換
      @top_scores = top_score_counts.map { |(title, category), count| 
        { title: title, category: category, count: count } 
      }
      
      # 最近評価してくれたユーザー
      @recent_evaluators = @recent_received_evaluations.map(&:evaluator).uniq.take(5)
      
    # indexアクション全体の rescue ブロック (例外処理)
    rescue => e
      # エラーの詳細をログに出力
      Rails.logger.error "Dashboard Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # エラーが発生した場合、画面表示用にデフォルト値を設定
      @recent_received_evaluations = []
      @recent_sent_evaluations = []    
      @total_received = 0
      @total_given = 0
      @total_checked_items = 0
      @top_scores = [] 
      @recent_evaluators = []
    end
  end
end
