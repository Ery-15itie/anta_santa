class ValueCategory < ApplicationRecord
  # 1つのカテゴリーは、たくさんのカードを持つ
  has_many :value_cards, dependent: :destroy

  # データの入力必須チェック
  validates :name, presence: true, uniqueness: true
  validates :theme_color, presence: true
  validates :icon_key, presence: true
end
