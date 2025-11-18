class Api::V1::EvaluationsController < ApplicationController
  # 評価機能は認証済みユーザーのみが利用可能
  before_action :authenticate_user! 

  # POST /api/v1/evaluations
  # 新しい評価（サンタ通知）を作成
  def create
    # 評価処理全体をトランザクションで囲む
    # これにより、EvaluationとEvaluationScoreのどちらかが失敗した場合、全てロールバックされる
    ActiveRecord::Base.transaction do
      
      # 1. Evaluationの作成
      # 評価者(evaluator)はcurrent_user, 被評価者(evaluated)はパラメータから取得
      @evaluation = current_user.sent_evaluations.build(evaluated_id: evaluation_params[:evaluated_id])
      
      # その他の属性を設定
      @evaluation.message = evaluation_params[:message]
      @evaluation.template_id = evaluation_params[:template_id] # 使用テンプレートID

      unless @evaluation.save
        raise ActiveRecord::Rollback # 保存失敗時はトランザクションをロールバック
      end

      # 2. EvaluationScoreの作成（TemplateItemごとの点数）
      scores_attributes = evaluation_params[:scores]
      
      # scores_attributesが有効な配列であることを確認
      if scores_attributes.nil? || !scores_attributes.is_a?(Array)
        @evaluation.errors.add(:scores, "評価項目（スコア）が正しくありません。")
        raise ActiveRecord::Rollback
      end

      scores_attributes.each do |score_attr|
        score = @evaluation.evaluation_scores.build(
          template_item_id: score_attr[:template_item_id],
          score: score_attr[:score],
          is_checked: score_attr[:is_checked]
        )
        
        unless score.save
          # スコアの保存失敗時もロールバック
          # @evaluationにエラーを追加して、最終的なエラーメッセージに含める
          score.errors.full_messages.each { |msg| @evaluation.errors.add(:base, "スコア項目エラー: #{msg}") }
          raise ActiveRecord::Rollback 
        end
      end
    end

    # トランザクションの結果判定
    if @evaluation.persisted? && @evaluation.errors.empty?
      render json: {
        status: 201,
        message: '評価が正常に作成され、サンタ通知が送られました。',
        data: EvaluationSerializer.new(@evaluation).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: 422,
        message: "評価の作成に失敗しました: #{@evaluation.errors.full_messages.to_sentence}"
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 404,
      message: '評価に必要なリソースが見つかりませんでした（ユーザーまたはテンプレート）'
    }, status: :not_found
  end
  
  # GET /api/v1/evaluations
  # 受信した評価（サンタ通知）一覧を取得
  def index
    @evaluations = current_user.received_evaluations.includes(
      :evaluator, 
      evaluation_scores: :template_item
    ).order(created_at: :desc)
    
    render json: {
      status: 200,
      data: EvaluationSerializer.new(@evaluations, include: [:evaluator, :evaluation_scores]).serializable_hash[:data].map { |item| item[:attributes] }
    }, status: :ok
  end
  
  # GET /api/v1/evaluations/:id
  # 特定の評価を取得
  def show
    @evaluation = current_user.received_evaluations.includes(
      :evaluator, 
      evaluation_scores: :template_item
    ).find(params[:id])
    
    render json: {
      status: 200,
      data: EvaluationSerializer.new(@evaluation, include: [:evaluator, :evaluation_scores]).serializable_hash[:data][:attributes]
    }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 404,
      message: '指定された評価（サンタ通知）が見つかりませんでした。'
    }, status: :not_found
  end

  private

  # 許可するパラメータを定義
  def evaluation_params
    params.require(:evaluation).permit(
      :evaluated_id, # 被評価者ID (必須)
      :template_id,  # 使用テンプレートID (必須)
      :message,      # メッセージ（任意）
      # EvaluationScoreの配列を受け入れる
      scores: [
        :template_item_id, # 評価項目ID (必須)
        :score,            # 点数 (必須)
        :is_checked        # チェックマーク (任意)
      ]
    )
  end
end
