class EvaluationsController < ApplicationController
  before_action :authenticate_user! # サインインしているユーザーのみアクセス可能

  def index
    if current_user
      # received_evaluations は evaluated_user が current_user である評価
      @received_evaluations = current_user.received_evaluations.includes(:evaluator).order(created_at: :desc)
      
      # sent_evaluations は evaluator が current_user である評価
      @sent_evaluations = current_user.sent_evaluations.includes(:evaluated_user).order(created_at: :desc)
    else
      @received_evaluations = Evaluation.none
      @sent_evaluations = Evaluation.none
    end
    
    if params[:tab].blank? || params[:tab] == 'received'
      @evaluations = @received_evaluations
    else
      @evaluations = @sent_evaluations
    end
  end

  def show
    @evaluation = Evaluation.find(params[:id])
    
    unless @evaluation.evaluated_user == current_user || @evaluation.evaluator == current_user
      redirect_to evaluations_path, alert: "そのお手紙を閲覧する権限がありません。"
    end
  end

  def new
    # 送信相手のIDが必須
    unless params[:receiver_id]
      redirect_to users_path, alert: "お手紙を送る相手を選択してください。"
      return
    end
    
    @receiver = User.find(params[:receiver_id])
    # 評価に使用するテンプレートをロード
    @template = Template.first 

    # テンプレートが存在しない場合はエラーを出す（システム設定の問題）
    unless @template
      redirect_to users_path, alert: "評価テンプレートが設定されていません。管理者にお問い合わせください。"
      return
    end
    
    @evaluation = current_user.sent_evaluations.build(evaluated_user_id: @receiver.id, template_id: @template.id)
    
    # 自身へのお手紙送信は禁止
    if @receiver == current_user
      redirect_to users_path, alert: "自分自身にお手紙は送れません。"
    end
    
    # フォーム用に evaluation_scores をビルド
    @template.template_items.each do |item|
      @evaluation.evaluation_scores.build(template_item_id: item.id)
    end
  end

  def create
    @evaluation = current_user.sent_evaluations.build(evaluation_params)
    
    if @evaluation.save
      redirect_to evaluations_path(tab: :sent), notice: "お手紙を「#{@evaluation.evaluated_user.username}」さんに送りました。"
    else
      # エラー時に @receiver と @template を再ロード
      @receiver = User.find(evaluation_params[:evaluated_user_id])
      @template = Template.find(evaluation_params[:template_id]) 
      # バリデーションエラー時は scores の再ビルドは不要（フォームに値が残っているため）
      render :new, status: :unprocessable_entity
    end
  end

  private

  def evaluation_params
    # template_id と evaluation_scores_attributes を許可リストに追加
    params.require(:evaluation).permit(:evaluated_user_id, 
                                       :template_id, 
                                       :message,
                                       evaluation_scores_attributes: [:id, :template_item_id, :score, :_destroy])
  end
end
