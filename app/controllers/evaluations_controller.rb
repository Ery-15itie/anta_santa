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
    # includesで関連モデルをプリロード (N+1問題対策)
    @evaluation = Evaluation.includes(
      :evaluator, 
      :evaluated_user, 
      evaluation_scores: :template_item
    ).find(params[:id])

    # 閲覧権限のチェック
    # 評価者(evaluator)か評価対象者(evaluated_user)のどちらかであれば閲覧可能
    unless @evaluation.evaluated_user == current_user || @evaluation.evaluator == current_user
      redirect_to evaluations_path, alert: "アクセス権限がありません。"
      return
    end

    # ビューでチェックされた項目数とリストを表示するために、scoreが1の項目を抽出
    @scores = @evaluation.evaluation_scores.select { |es| es.score.to_s == '1' }
    
    # 抽出後のデバッグログ（開発環境でのみ有効）
    Rails.logger.debug "=== チェックされたスコア数: #{@scores.count} ==="
  end

  # 新規作成フォーム
  def new
    @evaluation = current_user.evaluations_given.build
    prepare_new_form_data
  end

  # 評価作成
  def create
    # === デバッグログ開始 ===
    Rails.logger.debug "=== 受信パラメータ ==="
    Rails.logger.debug params.inspect
    Rails.logger.debug "=== evaluation_params ==="
    Rails.logger.debug evaluation_params.inspect
    # === デバッグログ終了 ===
    
    @evaluation = current_user.evaluations_given.build(evaluation_params)
    
    # titleカラムのNOT NULL制約を満たすため、titleを自動設定
    @evaluation.title = generate_evaluation_title(@evaluation)
    
    # === デバッグログ (バリデーション前) ===
    Rails.logger.debug "=== バリデーション前の evaluation_scores ==="
    @evaluation.evaluation_scores.each_with_index do |score, index|
      Rails.logger.debug "Score #{index}: template_item_id=#{score.template_item_id}, score=#{score.score.inspect}"
    end
    # === デバッグログ終了 ===
    
    if @evaluation.save
      redirect_to evaluations_path, notice: '評価を送信しました!'
    else
      # === デバッグログ (バリデーションエラー) ===
      Rails.logger.debug "=== バリデーションエラー ==="
      Rails.logger.debug @evaluation.errors.full_messages
      # === デバッグログ終了 ===
      
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
    
    # find_or_initialize_by を使用してスコアを初期化
    @template.template_items.each do |item|
      @evaluation.evaluation_scores.find_or_initialize_by(template_item_id: item.id) do |score|
        score.score ||= 0
      end
    end
  end

  # titleを自動生成するメソッド
  def generate_evaluation_title(evaluation)
    # find_by を使用して、レコードが存在しない場合でもエラーにならないようにする
    template = Template.find_by(id: evaluation.template_id)
    evaluated_user = User.find_by(id: evaluation.evaluated_user_id)
    
    if template && evaluated_user
      "#{template.title} - #{evaluated_user.name}への評価 (#{Date.current.strftime('%Y/%m/%d')})"
    else
      # 関連レコードが見つからない場合は、フォールバックのタイトルを設定
      "評価タイトル (未定義)"
    end
  end
  
  def evaluation_params
    params.require(:evaluation).permit(
      :evaluated_user_id,
      :template_id,
      :message,
      :title,
      evaluation_scores_attributes: [:id, :template_item_id, :score, :_destroy]
    )
  end
end
