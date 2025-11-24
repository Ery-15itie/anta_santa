class PagesController < ApplicationController
  # ログイン不要ページの設定
  skip_before_action :authenticate_user!, only: [:guide, :terms, :privacy, :contact], raise: false

  def guide
  end

  def terms
  end

  def privacy
  end

  def contact
  end
end
