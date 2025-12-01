class UserReflection < ApplicationRecord
  belongs_to :user
  belongs_to :reflection_question

  # 1つの質問に対して、1人のユーザーは1つの回答しか持てない（重複防止）
  validates :reflection_question_id, uniqueness: { scope: :user_id }
end
