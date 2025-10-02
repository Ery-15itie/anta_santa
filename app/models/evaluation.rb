class Evaluation < ApplicationRecord
  belongs_to :evaluator
  belongs_to :evaluated_user
  belongs_to :template
end
