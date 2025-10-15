class EvaluationsController < ApplicationController
  before_action :authenticate_user! # 認証済みのユーザーのみアクセス可能とする

  # 評価一覧
  def index
    # 自分が受け取った公開済みの評価一覧
    @evaluations_received = current_user.evaluations_received.published.recent
    # 自分が送った評価一覧
    @evaluations_given = current_user.evaluations_given.recent
  end

  # 評価詳細
  def show
    @evaluation = Evaluation.includes(evaluation_scores: :template_item).find(params[:id])
    unless @evaluation.evaluated_user == current_user || @evaluation.evaluator == current_user
      redirect_to dashboard_path, alert: "アクセス権限がありません。"
    end
  end

  # 新規作成フォーム
  def new
    @evaluation = current_user.evaluations_given.build
    prepare_new_form_data
  end

  # 評価作成
  def create
    @evaluation = current_user.evaluations_given.build(evaluation_params)
    
    if @evaluation.save
      redirect_to evaluations_path, notice: '評価を送信しました!'
    else
      # エラー時は再度フォームを表示するためにデータを準備し、render :new を実行
      prepare_new_form_data
      render :new, status: :unprocessable_entity
    end
  end

  private

  # フォームに必要なデータを準備する
  def prepare_new_form_data
    # 評価対象ユーザーのリスト（自分自身を除く）
    @target_users = User.where.not(id: current_user.id).pluck(:name, :id)
    # 使用するテンプレートを取得
    @template = Template.find_by(title: '大人のサンタさん通知表 - 評価シート')

    # テンプレートがない場合はエラー処理（実運用では必須）
    unless @template
      redirect_to dashboard_path, alert: "評価テンプレートが見つかりませんでした。"
      return
    end
    
    # フォームに初期データをセットするために、テンプレートの項目に基づき EvaluationScore を初期化
    if @evaluation.new_record?
      @template.template_items.each do |item|
        unless @evaluation.evaluation_scores.any? { |score| score.template_item_id == item.id }
          @evaluation.evaluation_scores.build(template_item_id: item.id)
        end
      end
    end
  end

  def evaluation_params
    params.require(:evaluation).permit(
      :evaluated_user_id,
      :template_id,
      :message,
      evaluation_scores_attributes: [:id, :template_item_id, :score, :_destroy]
    )
  end
end
