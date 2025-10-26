class RelationshipsController < ApplicationController
  # フォロー/アンフォローは認証済みユーザーのみ実行可能
  before_action :authenticate_user!

  # POST /relationships (フォロー実行)
  def create
    # followed_id (フォローされるユーザーID) をパラメータから取得
    user = User.find(params[:followed_id])
    
    # current_user のフォローメソッドを実行
    current_user.follow(user)
    
    # フォロー後、対象ユーザーのプロフィールページに戻る
    flash[:notice] = "#{user.username} さんをフォローしました。"
    redirect_to user
  end

  # DELETE /relationships/:id (アンフォロー実行)
  def destroy
    # ビューからRelationshipレコードのIDを受け取り、それを元にリレーションを取得
    relationship = current_user.active_relationships.find(params[:id])
    user = relationship.followed
    
    # フォロー解除を実行
    relationship.destroy
    
    # アンフォロー後、対象ユーザーのプロフィールページに戻る
    flash[:notice] = "#{user.username} さんのフォローを解除しました。"
    redirect_to user
  end
end
