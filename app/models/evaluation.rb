class Evaluation < ApplicationRecord
  belongs_to :evaluator, class_name: 'User'
  belongs_to :evaluated_user, class_name: 'User'
  belongs_to :template
  has_many :evaluation_scores, dependent: :destroy

  enum status: { draft: 0, submitted: 1, published: 2 }

  validates :evaluator_id, presence: true
  validates :evaluated_user_id, presence: true
  validates :template_id, presence: true
  validate :cannot_evaluate_self

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(evaluated_user: user) }
  scope :published_only, -> { where(status: :published) }

  accepts_nested_attributes_for :evaluation_scores,
                                 allow_destroy: true,
                                 reject_if: :all_blank

  # チェックされた項目数
  def checked_items_count
    evaluation_scores.where(is_checked: true).count
  end

  # カテゴリ別のチェック項目
  def checked_items_by_category
    evaluation_scores.includes(:template_item)
                     .where(is_checked: true)
                     .group_by { |score| score.template_item.category }
  end

  private

  def cannot_evaluate_self
    errors.add(:evaluated_user_id, "自分自身は評価できません") if evaluator_id == evaluated_user_id
  end
end
