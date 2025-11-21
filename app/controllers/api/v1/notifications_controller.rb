class Api::V1::NotificationsController < ApplicationController
  # 通知機能は認証済みユーザーのみが利用可能
  before_action :authenticate_user! 

  # GET /api/v1/notifications
  # 現在のユーザー宛ての通知をすべて取得 (最新順)
  def index
    # current_user.notifications は Notificationモデルの recipient_id で絞り込まれている
    @notifications = current_user.notifications.order(created_at: :desc)
    
    render json: {
      status: 200,
      message: '通知一覧を正常に取得しました。',
      # NotificationSerializerを使って整形
      data: NotificationSerializer.new(@notifications).serializable_hash[:data].map { |item| item[:attributes] }
    }, status: :ok
  end

  # PATCH /api/v1/notifications/:id
  # 特定の通知を既読にする
  def update
    # current_user宛ての通知のみを検索し、セキュリティを確保
    @notification = current_user.notifications.find(params[:id])

    # read_at に現在時刻を入れることで「既読」とする
    if @notification.update(read_at: Time.current)
      render json: {
        status: 200,
        message: '通知を既読にしました。',
        data: NotificationSerializer.new(@notification).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: {
        status: 422,
        message: '既読状態の更新に失敗しました。'
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 404,
      message: '指定された通知が見つかりませんでした。'
    }, status: :not_found
  end
end
