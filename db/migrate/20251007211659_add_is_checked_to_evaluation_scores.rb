class AddIsCheckedToEvaluationScores < ActiveRecord::Migration[7.2]
  def change
    add_column :evaluation_scores, :is_checked, :boolean, default: false, null: false
  end
end
