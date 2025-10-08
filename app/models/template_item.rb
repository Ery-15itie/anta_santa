class TemplateItem < ApplicationRecord
  belongs_to :template
  has_many :evaluation_scores, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :item_type, presence: true, inclusion: { in: %w[checkbox score text boolean] }
  validates :weight, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  default_scope { order(position: :asc) }
end
