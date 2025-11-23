class AddDetailsToEmotionLogs < ActiveRecord::Migration[7.2]
  def change
    # intensity カラムが存在しない場合のみ追加
    unless column_exists?(:emotion_logs, :intensity)
      add_column :emotion_logs, :intensity, :integer, default: 3, null: false
    end
    
    # magic_powder カラムが存在しない場合のみ追加
    unless column_exists?(:emotion_logs, :magic_powder)
      add_column :emotion_logs, :magic_powder, :integer, default: 0, null: false
    end
  end
end
