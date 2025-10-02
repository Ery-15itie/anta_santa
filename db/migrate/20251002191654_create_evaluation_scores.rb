class CreateEvaluationScores < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluation_scores do |t|
      t.references :evaluation, null: false, foreign_key: true
      t.references :template_item, null: false, foreign_key: true
      t.integer :score
      t.text :comment

      t.timestamps
    end
  end
end
