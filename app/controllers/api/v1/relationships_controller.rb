class Api::V1::RelationshipsController < ApplicationController
  # フォロー機能は認証済みユーザーのみが利用可能
  before_action :authenticate_user! 

  # POST /api/v1/relationships
  # ユーザーをフォローする
  def create
    # パラメータからフォロー対象のユーザーIDを取得
    followed_id = relationship_params[:followed_id]
    followed_user = User.find_by(id: followed_id)

    if followed_user.nil?
      return render_not_found("フォロー対象のユーザーが見つかりませんでした。")
    end

    if current_user.following?(followed_user)
      return render_unprocessable_entity("すでにこのユーザーをフォローしています。")
    end

    # Relationshipを作成
    relationship = current_user.active_relationships.build(followed_id: followed_id)
    
    if relationship.save
      render json: {
        status: 201,
        message: "#{followed_user.username} をフォローしました。",
        data: RelationshipSerializer.new(relationship).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render_unprocessable_entity("フォローに失敗しました。")
    end
  end

  # DELETE /api/v1/relationships/:id
  # ユーザーをアンフォローする
  def destroy
    # Relationship IDを params[:id] として受け取り、そのリレーションシップを見つける
    relationship = current_user.active_relationships.find_by(followed_id: params[:id])

    if relationship.nil?
      # params[:id] が Relationship ID ではなく followed_id の場合を想定（よりRESTfulなのはRelationship ID）
      # ここでは params[:id] を followed_id として扱い、柔軟に対応
      followed_user = User.find_by(id: params[:id])
      
      if followed_user && current_user.following?(followed_user)
        relationship = current_user.active_relationships.find_by(followed: followed_user)
      end
    end

    unless relationship
      return render_not_found("このユーザーとのフォロー関係が見つかりません。")
    end

    relationship.destroy
    render json: {
      status: 200,
      message: 'フォローを解除しました。'
    }, status: :ok
  end

  private

  # 許可するパラメータを定義
  def relationship_params
    params.require(:relationship).permit(:followed_id)
  end

  # エラーレスポンスヘルパー
  def render_not_found(message)
    render json: { 
      status: 404, 
      message: message 
    }, status: :not_found
  end

  def render_unprocessable_entity(message)
    render json: { 
      status: 422, 
      message: message 
    }, status: :unprocessable_entity
  end
end
