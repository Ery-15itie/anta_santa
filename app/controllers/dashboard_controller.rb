class DashboardController < ApplicationController
  # ログイン必須
  before_action :authenticate_user!

  # ログインユーザー向けのホーム画面
  def index
    @user = current_user
    # 評価やフレンド情報などをここで取得
  end
end
