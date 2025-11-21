class EvaluationScoreSerializer
  include JSONAPI::Serializer

  # スコアの基本属性
  attributes :id, :score, :is_checked, :template_item_id, :created_at
  
  # テンプレートアイテムの情報も含める
  belongs_to :template_item, serializer: TemplateItemSerializer
end
