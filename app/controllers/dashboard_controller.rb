class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    
    # 受け取った評価（エラー対策で配列を保証）
    @received_evaluations = @user.evaluations_received
                                  .includes(:evaluator, :evaluation_scores)
                                  .order(created_at: :desc)
                                  .limit(10) rescue []
    
    # 統計情報（エラー対策でデフォルト値を設定）
    @total_received = @user.evaluations_received.count rescue 0
    @total_given = @user.evaluations_given.count rescue 0
    @total_checked_items = @user.evaluations_received
                                .joins(:evaluation_scores)
                                .where(evaluation_scores: { is_checked: true })
                                .count rescue 0
  rescue => e
    # エラーログ出力
    Rails.logger.error "Dashboard Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    # デフォルト値を設定
    @received_evaluations = []
    @total_received = 0
    @total_given = 0
    @total_checked_items = 0
  end
end
