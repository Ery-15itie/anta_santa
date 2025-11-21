class Api::V1::EmotionLogsController < ApplicationController
  # 感情ログ機能は認証済みユーザーのみが利用可能
  before_action :authenticate_user! 
  # show, update, destroy の前にログを見つける
  before_action :set_emotion_log, only: [:show, :update, :destroy]

  # GET /api/v1/emotion_logs
  # 現在のユーザーが作成したすべての感情ログを取得（最新順）
  def index
    @emotion_logs = current_user.emotion_logs.order(created_at: :desc)
    
    render json: {
      status: 200,
      # 複数のログをシリアライズし、attributes部分のみを抽出
      data: EmotionLogSerializer.new(@emotion_logs).serializable_hash[:data].map { |item| item[:attributes] }
    }, status: :ok
  end

  # GET /api/v1/emotion_logs/:id
  # 特定の感情ログを取得
  def show
    render json: {
      status: 200,
      data: EmotionLogSerializer.new(@emotion_log).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  # POST /api/v1/emotion_logs
  # 新しい感情ログを作成
  def create
    @emotion_log = current_user.emotion_logs.build(emotion_log_params)

    if @emotion_log.save
      render json: {
        status: 201,
        message: '感情ログが正常に作成されました。',
        data: EmotionLogSerializer.new(@emotion_log).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: 422,
        message: "感情ログの作成に失敗しました: #{@emotion_log.errors.full_messages.to_sentence}"
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/emotion_logs/:id
  # 感情ログを更新
  def update
    if @emotion_log.update(emotion_log_params)
      render json: {
        status: 200,
        message: '感情ログが正常に更新されました。',
        data: EmotionLogSerializer.new(@emotion_log).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: {
        status: 422,
        message: "感情ログの更新に失敗しました: #{@emotion_log.errors.full_messages.to_sentence}"
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/emotion_logs/:id
  # 感情ログを削除
  def destroy
    @emotion_log.destroy
    head :no_content # 204 No Content を返す
  end

  private

  # 現在のユーザーに紐づく感情ログのみを取得 (セキュリティ対策)
  def set_emotion_log
    @emotion_log = current_user.emotion_logs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # ログが見つからない、または他のユーザーのログにアクセスしようとした場合
    render json: {
      status: 404,
      message: '指定された感情ログが見つかりませんでした。'
    }, status: :not_found
  end

  # 許可するパラメータを定義
  def emotion_log_params
    params.require(:emotion_log).permit(:body, :emotion, :intensity)
  end
end
