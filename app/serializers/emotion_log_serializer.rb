# EmotionLogオブジェクトをJSON形式に整形
class EmotionLogSerializer
  include JSONAPI::Serializer
  
  # 感情ログの属性を定義
  attributes :id, :body, :emotion, :intensity, :created_at, :updated_at

  # 関連ユーザー情報を含める必要がある場合、ここで belongs_to :user を定義
end
