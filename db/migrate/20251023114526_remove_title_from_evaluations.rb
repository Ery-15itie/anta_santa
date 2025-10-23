class RemoveTitleFromEvaluations < ActiveRecord::Migration[7.1]
  def change
    # title カラムが評価テーブルに残っている場合に削除する
    # check_if_column_existsを付けて安全性を高める
    if column_exists?(:evaluations, :title)
      remove_column :evaluations, :title, :string 
    end
  end
end
