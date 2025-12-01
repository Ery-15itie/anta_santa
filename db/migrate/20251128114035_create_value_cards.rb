class CreateValueCards < ActiveRecord::Migration[7.0]
  def change
    create_table :value_cards do |t|
      # カテゴリーとの紐付け ※必須
      t.references :value_category, null: false, foreign_key: true
      
      # カード名（例：好奇心）※必須
      t.string :name, null: false
      
      # 説明文（例：新しいことを知るワクワク...）※必須
      t.text :description, null: false

      t.timestamps
    end

    # 同じカテゴリーの中に、同じ名前のカードが重複しないようにする
    add_index :value_cards, [:value_category_id, :name], unique: true
  end
end
