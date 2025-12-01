class ValueCard < ApplicationRecord
  # カードは必ずどれか1つのカテゴリーに所属
  belongs_to :value_category

  # カードはたくさんの「ユーザーの選択」に使われる
  has_many :user_card_selections, dependent: :destroy

  # データの入力必須チェック
  validates :name, presence: true
  validates :description, presence: true
end
