class CreateEvaluations < ActiveRecord::Migration[7.0]
  def change
    create_table :evaluations do |t|
      # 評価者 (evaluator) と評価対象者 (evaluated_user) を User テーブルに結びつける
      t.references :evaluator, null: false, foreign_key: { to_table: :users } 
      t.references :evaluated_user, null: false, foreign_key: { to_table: :users } 
      
      t.references :template, null: false, foreign_key: true

      t.string :title, null: false
      t.integer :status, default: 0 # 例: 0=下書き, 1=提出済
      t.integer :total_score, default: 0

      t.timestamps
    end
  end
end
