class CreateEmotionLogs < ActiveRecord::Migration[7.2]
  def change
    # 感情ログテーブルを作成
    create_table :emotion_logs do |t|
      # ユーザーとの関連付け (Userが削除されたらログも削除)
      t.references :user, null: false, foreign_key: true 
      t.text :body # ログの本文
      t.string :emotion # 感情ラベル (例: happy, sad, angry)
      t.integer :intensity # 感情の強度 (例: 1〜5)

      t.timestamps
    end
  end
end
