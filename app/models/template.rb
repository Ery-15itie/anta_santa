class Template < ApplicationRecord
  belongs_to :user
  has_many :template_items, dependent: :destroy
  has_many :evaluations, dependent: :restrict_with_error

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  scope :public_templates, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }

  accepts_nested_attributes_for :template_items, 
                                 allow_destroy: true,
                                 reject_if: :all_blank
end
