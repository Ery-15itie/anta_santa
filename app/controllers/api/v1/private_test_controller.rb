class Api::V1::PrivateTestController < ApplicationController
  # Deviseのヘルパーメソッドを使って、リクエスト前に認証（JWTトークンチェック）を要求
  before_action :authenticate_user! 

  # GET /api/v1/private/test
  def index
    render json: {
      status: 200,
      message: '認証に成功しました。これは保護されたエンドポイントです。',
      user: {
        id: current_user.id,
        email: current_user.email,
        username: current_user.username
      }
    }, status: :ok
  end
end
