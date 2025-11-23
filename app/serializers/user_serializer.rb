# Fast JSON API/JSONAPI::Serializerを利用して、UserオブジェクトをJSON形式に整形
class UserSerializer
  include JSONAPI::Serializer
  
  # クライアントに返したい基本属性を定義
  attributes :id, :email, :username, :image_url, :created_at, :updated_at

  # =========================================================
  # 動的な属性（current_userからの視点）
  # =========================================================
  
  # フォローされている数（フォロワー数）
  attribute :followers_count do |user|
    user.followers.count
  end
  
  # フォローしている数
  attribute :following_count do |user|
    user.following.count
  end

  # 現在のユーザー（リクエストしているユーザー）が、このユーザーをフォローしているか？
  # UsersControllerのshowアクションから params: { is_following: ... } を受け取ることを想定
  attribute :is_following do |user, params|
    # コントローラで計算されたis_followingを優先して返す
    params[:is_following] if params[:is_following].present?
  end
  
  # ユーザー自身の感情ログ数
  attribute :emotion_logs_count do |user|
    user.emotion_logs.count
  end
end
