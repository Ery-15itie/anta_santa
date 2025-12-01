class ReflectionQuestion < ApplicationRecord
  has_many :user_reflections, dependent: :destroy
  
  validates :body, presence: true
  validates :position, presence: true
end
