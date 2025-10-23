class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  
  # user index から送られる :receiver_id またはフォームからの :evaluated_user_id を受け取る
  before_action :set_evaluated_user, only: [:new, :create] 
  
  # 評価テンプレート画面の表示と送信を優先するため、フォロー制限は一時的にコメントアウト
  # before_action :check_follow_relationship, only: [:new, :create] 
  
  before_action :set_evaluation, only: [:show, :destroy] 

  # 評価一覧
  def index
    @evaluations_received = current_user.evaluated_user_evaluations.recent
    @evaluations_given = current_user.evaluator_evaluations.recent
  end

  # 評価作成フォーム
  def new
    # 評価オブジェクトのビルド (evaluator_id は current_user で設定)
    @evaluation = current_user.evaluator_evaluations.build
    
    # 評価テンプレートの取得と初期化 (ビュー対応)
    @template = Template.first 
    
    unless @template
      # パス修正: dashboard_index_path -> dashboard_path
      redirect_to dashboard_path, alert: "評価テンプレートが設定されていません。"
      return
    end

    # EvaluationScore オブジェクトを初期化（fields_for のために必須）
    @template.template_items.each do |item|
      # 各 TemplateItem に対応する EvaluationScore を0(未チェック)で初期化
      @evaluation.evaluation_scores.build(template_item_id: item.id, score: 0)
    end
    
    # ビューの f.select :evaluated_user_id のための選択肢
    @target_users = User.where.not(id: current_user.id).pluck(:username, :id)

    # new アクションに evaluated_user_id が渡された場合、@evaluationにセット
    if @evaluated_user
      @evaluation.evaluated_user_id = @evaluated_user.id
    end
  end

  # 評価作成処理
  def create
    # evaluation_paramsの中に:evaluated_user_idを含めてビルドすることでバリデーションエラーを回避
    @evaluation = current_user.evaluator_evaluations.build(evaluation_params)
    
    # エラー時の再描画に必要なテンプレートを再設定
    @template = Template.find_by(id: params[:evaluation][:template_id])

    if @evaluation.save
      # パス修正: dashboard_index_path -> dashboard_path
      redirect_to dashboard_path, notice: "評価（メッセージ）を#{@evaluation.evaluated_user.username}さんに送信しました！"
    else
      # 失敗時は再描画に必要な変数を再設定
      @evaluated_user = @evaluation.evaluated_user # エラー時に評価対象のユーザーを取得
      @target_users = User.where.not(id: current_user.id).pluck(:username, :id) # 選択肢
      
      # エラー時も評価スコアが正しく表示されるようにする
      if @evaluation.evaluation_scores.none?
         @template.template_items.each do |item|
            @evaluation.evaluation_scores.build(template_item_id: item.id, score: 0)
         end
      end

      flash.now[:alert] = "評価の送信に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  # 評価詳細 ★追加★
  def show
    # @evaluation は set_evaluation で設定済み
    # ユーザーが評価者（送った人）または被評価者（受け取った人）であればアクセス可能
  end

  # 評価の削除（任意）
  def destroy
    # @evaluation は set_evaluation で設定済み
    
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
      :evaluated_user_id, # ここでIDを許可
      evaluation_scores_attributes: [:id, :template_item_id, :score] # ネストされた属性
    )
  end

  # 評価対象ユーザー（evaluated_user）を取得
  def set_evaluated_user
    # ユーザー一覧からの ID（receiver_id）を優先、またはフォームからのID
    id = params[:receiver_id] || params[:evaluated_user_id] 
    
    # IDが空の場合は処理を終了
    return if id.blank?

    @evaluated_user = User.find_by(id: id)

    if @evaluated_user.nil?
      redirect_to dashboard_path, alert: "評価対象ユーザーが見つかりませんでした。"
      return
    end
  end
  
  # IDから評価を取得し、権限チェックを行う ★追加★
  def set_evaluation
    # 評価者または被評価者である評価を取得
    @evaluation = Evaluation.find_by(id: params[:id], evaluator: current_user) || 
                  Evaluation.find_by(id: params[:id], evaluated_user: current_user)
    
    unless @evaluation
      redirect_to evaluations_path, alert: "権限のない評価、または見つからない評価です。"
    end
  end

  # def check_follow_relationship
  #   # ... (フォロー制限ロジック)
  # end
end
