class EvaluationsController < ApplicationController
  # ログインしているユーザーだけがアクセスできるようにする
  before_action :authenticate_user!
  before_action :set_evaluation, only: [:show] # :showアクションで評価を取得
  
  # GET /evaluations (メッセージ一覧)
  def index
    # 自分が受け取った評価（お手紙）のみを表示
    @evaluations = current_user.evaluations_received
                               .includes(:evaluator) # 評価者の情報を取得
                               .order(created_at: :desc)
    
    # 自分が送った評価（参考情報として）
    @evaluations_given = current_user.evaluations_given
                                     .includes(:evaluated_user)
                                     .order(created_at: :desc)
  end
  
  # GET /evaluations/:id (メッセージ詳細)
  def show
    # @evaluation は set_evaluation で取得済み

    # 評価対象者 または 評価者 でなければアクセス拒否
    unless @evaluation.evaluated_user == current_user || @evaluation.evaluator == current_user
      flash[:alert] = "このメッセージを閲覧する権限がありません。"
      redirect_to evaluations_path and return
    end
    
    # 評価スコア（チェックされた項目）を取得
    @scores = @evaluation.evaluation_scores
                         .includes(:template_item)
                         .where(score: 1)
                         .order('template_items.category', 'template_items.sub_category')
                         
    # カテゴリーごとにグループ化
    @grouped_scores = @scores.group_by { |s| s.template_item.category }
  end

  # GET /evaluations/new (評価フォームの表示)
  def new
    @evaluation = Evaluation.new
    prepare_new_form_data 
    
    # テンプレートがない場合のチェック（newアクションでのみリダイレクトが必要）
    unless @template_items
      flash[:alert] = "評価テンプレートが見つかりません。システム管理者に連絡してください。"
      redirect_to root_path and return
    end
  end

  # POST /evaluations (評価データの受け取りと保存)
  def create
    # テンプレートIDを取得
    default_template = Template.find_by(title: '大人のサンタさん通知表 - 評価シート') 

    # トランザクションを開始し、評価とスコアの保存を行う
    ActiveRecord::Base.transaction do
      # Evaluation（お手紙の基本情報）の作成
      @evaluation = Evaluation.new(evaluation_params)
      @evaluation.evaluator_id = current_user.id # 評価者のIDをセット

      # titleを自動生成して設定
      evaluated_user = User.find_by(id: @evaluation.evaluated_user_id)
      if evaluated_user
          @evaluation.title = "#{evaluated_user.name}さんへのサンタさん通知表"
      else
          @evaluation.title = "【緊急】評価対象者不明の通知表" # フォールバック
      end

      # テンプレートIDを設定
      unless default_template
          @evaluation.errors.add(:template, "評価テンプレートが見つかりません。")
          raise ActiveRecord::RecordInvalid, @evaluation
      end
      @evaluation.template_id = default_template.id

      # 評価対象ユーザーIDが必須のチェック
      unless @evaluation.evaluated_user_id.present?
          @evaluation.errors.add(:evaluated_user_id, "お手紙を送る相手を選択してください")
          raise ActiveRecord::RecordInvalid, @evaluation
      end

      if @evaluation.save
        # EvaluationScore（チェックされた項目）の作成
        item_ids = params.dig(:evaluation, :item_ids) || []

        item_ids.each do |item_id|
          # チェックされた項目ごとに EvaluationScore を作成
          @evaluation.evaluation_scores.create!(
            template_item_id: item_id,
            score: 1, # チェックボックスなのでスコアは1
            comment: nil 
          )
        end

        # 成功したら完了ページにリダイレクト
        flash[:notice] = "🎉 サンタさんのお手紙をそっと渡しました！感謝の気持ちが伝わりますように！"
        redirect_to evaluations_path(anchor: 'received') # 送信後、一覧画面にリダイレクト
      else
        # Evaluationのバリデーションエラーがあればここで捕捉
        raise ActiveRecord::Rollback
      end
    end # end of transaction

  rescue ActiveRecord::RecordInvalid => e
    # バリデーションエラーなどでトランザクションがロールバックした場合
    prepare_new_form_data # フォーム再表示のためにデータを再設定
    
    # 失敗したEvaluationオブジェクトのエラーメッセージを利用して表示
    error_message = @evaluation.errors.full_messages.join(', ') if @evaluation.present?
    
    flash.now[:alert] = "お手紙の送信に失敗しました: #{error_message || '不明なエラー'}"
    render :new, status: :unprocessable_entity
    
  rescue => e
    # その他の予期せぬエラー
    Rails.logger.error "Evaluation Create Error: #{e.message}\n#{e.backtrace.join("\n")}"
    prepare_new_form_data
    flash.now[:alert] = "評価送信中にシステムエラーが発生しました。"
    render :new, status: :internal_server_error
  end
  
  # show, edit, update, destroyなどのアクションは今回はスキップ

  private
  
  # show/submit/publishアクションで使う評価を取得 (IDで評価を取得する)
  def set_evaluation
    # eager loading を使って関連ユーザーを取得
    @evaluation = Evaluation.includes(:evaluator, :evaluated_user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "指定されたメッセージが見つかりません。"
    redirect_to evaluations_path and return
  end

  # newアクションとcreateアクションの両方で使うデータを準備するプライベートメソッド
  def prepare_new_form_data
    # @users の取得 (自分以外のユーザー)
    @users = User.where.not(id: current_user.id).pluck(:name, :id)
    
    # @template_items の取得
    default_template = Template.find_by(title: '大人のサンタさん通知表 - 評価シート') 
    @template_items = default_template&.template_items&.order(:position)
  end

  # Strong Parameters
  def evaluation_params
    params.require(:evaluation).permit(:evaluated_user_id, :message)
  end
end