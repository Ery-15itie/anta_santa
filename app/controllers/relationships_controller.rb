class RelationshipsController < ApplicationController
  # フォロー処理はログイン必須
  before_action :authenticate_user!

  # フォローする (POST /relationships)
  def create
    # フォローされるユーザーをパラメータから取得
    user = User.find(params[:followed_id])
    
    # 自分自身をフォローすることはできないようにする
    if current_user != user
      # Userモデルで定義した active_relationships を通してフォロー
      # << 演算子により、新しいRelationshipレコードが作成される
      current_user.following << user
      flash[:notice] = "#{user.username} さんのフォローを開始しました。"
    else
      # ここは通常起こらないが、念のため
      flash[:alert] = "自分自身をフォローすることはできません。"
    end
    
    # 直前のページに戻る
    redirect_back fallback_location: users_path
  end

  # フォロー解除する (DELETE /relationships/:id)
  def destroy
    # params[:id] がリレーションシップIDかユーザーIDかに関わらず、current_userがフォローしているリレーションシップを followed_id で検索して特定する。
    relationship = current_user.active_relationships.find_by(followed_id: params[:id])

    # リレーションシップが見つかった場合のみ削除
    if relationship
      user = relationship.followed
      relationship.destroy
      flash[:notice] = "#{user.username} さんのフォローを解除しました。"
    else
      flash[:alert] = "フォローが見つからなかったため、解除できませんでした。"
    end
    
    # 直前のページに戻る
    redirect_back fallback_location: users_path
  end
end
