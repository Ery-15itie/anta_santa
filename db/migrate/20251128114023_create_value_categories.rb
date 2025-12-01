class CreateValueCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :value_categories do |t|
      # カテゴリー名（例：学び・成長）※必須・重複不可
      t.string :name, null: false
      
      # テーマカラー（例：#4F46E5）※必須
      t.string :theme_color, null: false
      
      # アイコン識別キー（例：book_castle）※必須
      t.string :icon_key, null: false

      t.timestamps
    end

    # 同じ名前のカテゴリーが作られないようにする制約
    add_index :value_categories, :name, unique: true
  end
end
