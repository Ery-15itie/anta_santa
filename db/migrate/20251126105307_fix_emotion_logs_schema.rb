class FixEmotionLogsSchema < ActiveRecord::Migration[7.2]
  def change
    # 1. note カラムがあれば body にリネーム
    if column_exists?(:emotion_logs, :note)
      rename_column :emotion_logs, :note, :body
    end

    # 2. intensity カラムがなければ追加
    unless column_exists?(:emotion_logs, :intensity)
      add_column :emotion_logs, :intensity, :integer, default: 3, null: false
    end

    # 3. magic_powder カラムがなければ追加
    unless column_exists?(:emotion_logs, :magic_powder)
      add_column :emotion_logs, :magic_powder, :integer, default: 0, null: false
    end
  end
end
