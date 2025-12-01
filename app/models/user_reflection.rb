class UserReflection < ApplicationRecord
  belongs_to :user
  belongs_to :reflection_question
end
