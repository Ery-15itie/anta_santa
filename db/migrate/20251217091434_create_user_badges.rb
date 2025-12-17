class CreateUserBadges < ActiveRecord::Migration[7.0]
  def change
    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.string :badge_id, null: false
      t.datetime :earned_at, null: false

      t.timestamps
    end
    # 同じユーザーが同じバッジを2個持たないようにする
    add_index :user_badges, [:user_id, :badge_id], unique: true
  end
end
