class RelationshipsController < ApplicationController
  # ユーザーがサインインしていることを確認
  before_action :authenticate_user!

  # フォロー作成 (POST)
  def create
    # フォローする相手（followed_id）を取得
    user = User.find(params[:followed_id])

    # 既にフォローしている場合は何もしない
    unless current_user.following?(user)
      # フォローを実行
      current_user.follow(user)
    end

    # Turbo Stream を使ってボタン部分のみを更新
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user }
    end
  end

  # フォロー解除 (DELETE)
  def destroy
    # params[:id] には "followed_id" が入っているため、それを使ってリレーションシップを検索する
    # current_userのactive_relationshipsから、followed_idが一致するリレーションを取得
    relationship = current_user.active_relationships.find_by(followed_id: params[:id])

    # リレーションが存在すれば削除
    if relationship
      user = relationship.followed
      relationship.destroy
    end
    
    # Turbo Stream を使ってボタン部分のみを更新
    # ユーザー詳細画面での使用を想定
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user }
    end
  end
end
