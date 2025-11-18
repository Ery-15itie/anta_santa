class ApplicationController < ActionController::API
  # Deviseのヘルパーメソッド（current_user, user_signed_in? など）をAPIコントローラでも利用可能にするために必要
  include ActionController::Helpers
  
  # JWT認証が失敗した場合の共通エラー処理
  # 認証されていない場合 (JWTトークンがない、または無効) に実行される
  def authenticate_user!(options = {})
    unless user_signed_in?
      # 認証エラーの場合、401 Unauthorized ステータスとエラーメッセージを返す
      render json: { 
        status: 401, 
        message: '認証が必要です。ログインしてからアクセスしてください。' 
      }, status: :unauthorized
    end
  end
end
