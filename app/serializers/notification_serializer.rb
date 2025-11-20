class NotificationSerializer
  include JSONAPI::Serializer
  
  # 通知の基本属性
  attributes :id, :recipient_id, :actor_id, :type, :read_at, :created_at, :updated_at

  # 通知の内容 (notifiable)
  # NotifiableのIDとタイプを返すことで、クライアントは評価ならEvaluationAPI、フォローならRelationshipAPIにアクセスできる
  attribute :notifiable_id do |notification|
    notification.notifiable_id
  end
  
  attribute :notifiable_type do |notification|
    notification.notifiable_type
  end
  
  # 通知を起こしたユーザー（actor）の情報を含める
  belongs_to :actor, serializer: UserSerializer 
end
