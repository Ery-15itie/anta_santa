# RelationshipオブジェクトをJSON形式に整形
class RelationshipSerializer
  include JSONAPI::Serializer
  
  # Relationship自体の属性
  attributes :id, :created_at

  # Relationshipに関連するユーザーID
  attribute :follower_id do |relationship|
    relationship.follower_id
  end

  attribute :followed_id do |relationship|
    relationship.followed_id
  end
end
