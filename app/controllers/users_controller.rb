class UsersController < ApplicationController
  before_action :authenticate_user!

  # ユーザー一覧を表示するアクション
  def index
    # 現在のユーザー以外のすべてのユーザーを取得
    @users = User.where.not(id: current_user.id).order(:username)
  end

  # 個別ユーザーの詳細（評価作成画面への遷移に必要）
  def show
    @user = User.find(params[:id])
  end
end
