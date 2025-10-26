class UsersController < ApplicationController
  before_action :authenticate_user!

  # ユーザー一覧を表示するアクション（検索機能対応）
  def index
    # 現在のユーザー以外のすべてのユーザーを取得するベースクエリ
    users_query = User.where.not(id: current_user.id)

    if params[:search].present?
      # 検索クエリがあれば、ユーザー名で部分一致検索
      @users = users_query.where("username LIKE ?", "%#{params[:search]}%").order(:username)
    else
      # 検索クエリがなければ、すべてのユーザーをユーザー名でソート
      @users = users_query.order(:username)
    end
  end

  # 個別ユーザーの詳細（プロフィール）
  def show
    @user = User.find(params[:id])
  end

  # フォローしているユーザー一覧（フレンド一覧）
  def following
    # current_user がフォローしているユーザーのコレクションを取得
    @users = current_user.following.order(:username)
    # ビューは 'users/following.html.erb' を使用する
  end
end
