class PagesController < ApplicationController
  # ログイン不要ページの設定
  # ※ admin アクションはここには含めません（ログイン必須にするため！！）
  skip_before_action :authenticate_user!, only: [:guide, :terms, :privacy, :contact], raise: false

  def guide
  end

  def terms
  end

  def privacy
  end

  def contact
  end

  # ▼▼▼ 追加: 管理者画面表示用のアクション ▼▼▼
  def admin
    # ビュー (app/views/pages/admin.html.erb) を表示するだけ
  end
end
