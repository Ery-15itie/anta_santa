class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipient, only: [:new, :create]
  before_action :check_follow_relationship, only: [:new, :create]
  
  # 評価一覧
  def index
    # 自分が受け取った公開済みの評価一覧
    @evaluations_received = current_user.recipient_evaluations.recent
    # 自分が送った評価一覧
    @evaluations_given = current_user.sender_evaluations.recent
  end

  # 評価作成フォーム
  def new
    @evaluation = @recipient.recipient_evaluations.build(sender: current_user)
  end

  # 評価作成処理
  def create
    @evaluation = @recipient.recipient_evaluations.build(evaluation_params.merge(sender: current_user))
    
    if @evaluation.save
      redirect_to dashboard_index_path, notice: "評価（メッセージ）を#{User.model_name.human}（#{@recipient.username}）に送信しました！"
    else
      # 失敗時はnewテンプレートを再描画
      flash.now[:alert] = "評価の送信に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  # 評価の削除（任意）
  def destroy
    # 自分が送った評価のみ削除可能
    @evaluation = current_user.sender_evaluations.find(params[:id])
    
    if @evaluation.destroy
      redirect_to evaluations_path, notice: '評価を削除しました。'
    else
      redirect_to evaluations_path, alert: '評価の削除に失敗しました。'
    end
  end

  private

  def evaluation_params
    params.require(:evaluation).permit(:score, :comment, :is_public)
  end

  # 評価対象ユーザー（recipient）を取得
  def set_recipient
    @recipient = User.find_by(id: params[:recipient_id])
  end

  # 評価条件の確認（自分自身への評価禁止、フォロー関係の確認）
  def check_follow_relationship
    # ユーザーが存在しない、または自分自身を評価しようとした場合はエラー
    if @recipient.nil? || @recipient == current_user
      redirect_to dashboard_index_path, alert: "評価対象ユーザーが無効です。"
      return
    end

    # フォローしていないユーザーには評価を送信できない
    unless current_user.following?(@recipient)
      redirect_to user_path(@recipient), alert: "#{@recipient.username}さんをフォローしていません。フォロー後に評価を送信できます。"
    end
  end
end
