class Evaluation < ApplicationRecord
  # アソシエーション
  belongs_to :evaluator, class_name: 'User'
  belongs_to :evaluated_user, class_name: 'User'
  belongs_to :template
  has_many :evaluation_scores, dependent: :destroy

  # ステータス定義
  enum status: { draft: 0, submitted: 1, published: 2 }

  # スコープ定義
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(evaluated_user: user) }
  scope :published_only, -> { where(status: :published) }

  # ネストされた属性の許可
  accepts_nested_attributes_for :evaluation_scores,
                                 allow_destroy: true,
                                 reject_if: proc { |attributes| attributes['score'].blank? && attributes['template_item_id'].blank? }

  # 基本的なバリデーション
  validates :evaluator_id, presence: true
  validates :evaluated_user_id, presence: true
  validates :template_id, presence: true
  validates :message, presence: true 

  # カスタムバリデーション
  validate :cannot_evaluate_self
  validate :must_have_at_least_one_score 
  
  private

  # 自分自身を評価できないようにする
  def cannot_evaluate_self
    errors.add(:base, "自分自身は評価できません") if evaluator_id == evaluated_user_id
  end

  # 評価スコア（チェックボックス）が最低1つ存在するかチェック
  def must_have_at_least_one_score
    # scoreが 1 のレコードを、to_iで確実にカウント
    checked_scores = evaluation_scores.reject(&:marked_for_destruction?)
                                      .count { |score| score.score.to_i == 1 }

    if checked_scores < 1
      errors.add(:base, '1つ以上チェックしてください') 
    end
  end
end
