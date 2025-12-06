class AddIndexToEmotionLogs < ActiveRecord::Migration[7.2]
  def change
    # user_idで絞り込み、created_atで並び替える処理を高速化します
    add_index :emotion_logs, [:user_id, :created_at]
  end
end
