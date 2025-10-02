class EvaluationScore < ApplicationRecord
  belongs_to :evaluation
  belongs_to :template_item
end
