class Api::V1::UsersController < ApplicationController
  # すべてのアクションでJWT認証を要求
  before_action :authenticate_user!

  # GET /api/v1/users
  # ユーザー一覧を取得（将来的には検索機能を追加予定）
  def index
    # 現在のユーザー自身を除外して、最新登録順に20件返す
    @users = User.where.not(id: current_user.id).order(created_at: :desc).limit(20)

    render json: {
      status: 200,
      message: 'ユーザー一覧を正常に取得しました。',
      # UserSerializerを使ってJSONに整形
      data: UserSerializer.new(@users).serializable_hash[:data].map { |item| item[:attributes] }
    }, status: :ok
  end

  # GET /api/v1/users/:id
  # 特定のユーザーのプロフィールを取得
  def show
    @user = User.find(params[:id])
    
    # プロフィール情報に加えて、現在のユーザーとのフォロー状態もチェック
    is_following = current_user.following?(@user)
    
    # UserSerializerに動的な情報（is_following）をparamsとして渡す
    serialized_user = UserSerializer.new(@user, { 
      params: { 
        current_user: current_user, 
        is_following: is_following 
      } 
    }).serializable_hash[:data][:attributes]

    render json: {
      status: 200,
      message: 'ユーザープロフィールを正常に取得しました。',
      data: serialized_user
    }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 404,
      message: '指定されたユーザーが見つかりませんでした。'
    }, status: :not_found
  end

  # GET /api/v1/users/following
  # 現在のユーザーがフォローしているユーザーの一覧を取得
  def following
    # Userモデルに定義された has_many :following を利用
    @following_users = current_user.following.order(created_at: :desc)
    
    render json: {
      status: 200,
      message: 'フォロー中ユーザーの一覧を正常に取得しました。',
      data: UserSerializer.new(@following_users).serializable_hash[:data].map { |item| item[:attributes] }
    }, status: :ok
  end
end
