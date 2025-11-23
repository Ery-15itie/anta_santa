class ChangeEmotionInEmotionLogsToInteger < ActiveRecord::Migration[7.2]
  def up
    # emotionカラムをstring型からinteger型に変更
    remove_column :emotion_logs, :emotion, :string
    add_column :emotion_logs, :emotion, :integer, default: 8, null: false 
    # default: 8 は :neutral を意味
  end

  def down
    # 元に戻す場合は、再度カラムをstring型に戻す
    remove_column :emotion_logs, :emotion, :integer
    add_column :emotion_logs, :emotion, :string
  end
end
