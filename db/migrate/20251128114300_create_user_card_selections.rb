class CreateUserCardSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :user_card_selections do |t|
      # ユーザーとの紐付け ※必須
      t.references :user, null: false, foreign_key: true
      
      # カードとの紐付け ※必須
      t.references :value_card, null: false, foreign_key: true
      
      # 時間軸 (0:past, 1:current, 2:future) ※必須、デフォルトは現在(1)
      t.integer :timeframe, null: false, default: 1
      
      # 満足度 (未来のギャップ分析用 1-10) ※任意
      t.integer :satisfaction
      
      # そのカードを選んだ理由・ストーリー ※任意
      t.text :description

      t.timestamps
    end

    # 「1人のユーザー」が「同じ時間軸」で「同じカード」を重複して登録できないようにする制約
    # index名が長くなりすぎるのを防ぐため、nameオプションで名前を指定
    add_index :user_card_selections, [:user_id, :value_card_id, :timeframe], unique: true, name: 'index_unique_user_card_selection'
  end
end
