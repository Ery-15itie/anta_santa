class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  
  # user index から送られる :receiver_id またはフォームからの :evaluated_user_id を受け取る
  before_action :set_evaluated_user, only: [:new, :create] 
  
  before_action :set_evaluation, only: [:show, :destroy] 

  # 評価一覧
  def index
    @evaluations_received = current_user.evaluated_user_evaluations.recent
    @evaluations_given = current_user.evaluator_evaluations.recent
  end

  # 評価作成フォーム
  def new
    @evaluation = current_user.evaluator_evaluations.build
    
    @template = Template.first 
    
    unless @template
      redirect_to dashboard_path, alert: "評価テンプレートが設定されていません。"
      return
    end

    # EvaluationScore オブジェクトを初期化（fields_for のために必須）
    @template.template_items.each do |item|
      @evaluation.evaluation_scores.build(template_item_id: item.id, score: 0)
    end
    
    # フォローしているユーザーリストを取得
    @target_users = current_user.following.order(:username)

    if @evaluated_user
      @evaluation.evaluated_user_id = @evaluated_user.id
    end
  end

  # 評価作成処理
  def create
    @evaluation = current_user.evaluator_evaluations.build(evaluation_params)
    
    @template = Template.find_by(id: params[:evaluation][:template_id])

    if @evaluation.save
      redirect_to dashboard_path, notice: "評価（メッセージ）を#{@evaluation.evaluated_user.username}さんに送信しました！"
    else
      @evaluated_user = @evaluation.evaluated_user 
      
      # エラー再描画時もフォローしているユーザーリストを再取得
      @target_users = current_user.following.order(:username)
      
      if @evaluation.evaluation_scores.none?
         @template.template_items.each do |item|
            @evaluation.evaluation_scores.build(template_item_id: item.id, score: 0)
         end
      end

      flash.now[:alert] = "評価の送信に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  # 評価詳細
  def show
    # @evaluation は set_evaluation で設定済み
  end

  # 評価の削除（任意）
  def destroy
    if @evaluation.destroy
      redirect_to evaluations_path, notice: '評価を削除しました。'
    else
      redirect_to evaluations_path, alert: '評価の削除に失敗しました。'
    end
  end

  private

  def evaluation_params
    params.require(:evaluation).permit(
      :message, 
      :is_public,
      :template_id, 
      :evaluated_user_id, 
      evaluation_scores_attributes: [:id, :template_item_id, :score] 
    )
  end

  # 評価対象ユーザー（evaluated_user）を取得
  def set_evaluated_user
    id = params[:receiver_id] || params[:evaluation] && params[:evaluation][:evaluated_user_id]
    
    return if id.blank?

    @evaluated_user = User.find_by(id: id)

    if @evaluated_user.nil?
      redirect_to dashboard_path, alert: "評価対象ユーザーが見つかりませんでした。"
      return
    end
  end
  
  # IDから評価を取得し、権限チェックを行う
  def set_evaluation
    @evaluation = Evaluation.find_by(id: params[:id], evaluator: current_user) || 
                  Evaluation.find_by(id: params[:id], evaluated_user: current_user)
    
    unless @evaluation
      redirect_to evaluations_path, alert: "権限のない評価、または見つからない評価です。"
    end
  end
end
