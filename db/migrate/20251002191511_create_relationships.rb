class CreateRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :relationships do |t|
      # follower/followed を User テーブルに結びつけ
      t.references :follower, null: false, foreign_key: { to_table: :users } 
      t.references :followed, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    # 重複防止のための複合インデックス
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
