class EvaluationSerializer
  include JSONAPI::Serializer
  
  # 評価自体の基本属性
  attributes :id, :message, :template_id, :evaluated_id, :evaluator_id, :created_at, :updated_at

  # 関連付け (評価者、スコア)
  # シリアライズ時に :evaluator, :evaluation_scores を include で指定することで、関連データもネストしてJSONに含められる
  belongs_to :evaluator, serializer: UserSerializer
  has_many :evaluation_scores, serializer: EvaluationScoreSerializer
end
