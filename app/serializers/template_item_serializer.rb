class TemplateItemSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :description, :is_required, :item_type, :position, :template_id
  
  # 評価項目がどのテンプレートに属するかを示す
  # belongs_to :template
end