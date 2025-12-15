class AddPublicIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :public_id, :string

    # 一意性制約（同じIDは登録できない）とインデックス（検索高速化）を追加
    add_index :users, :public_id, unique: true
  end
end