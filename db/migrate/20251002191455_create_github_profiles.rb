class CreateGithubProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :github_profiles do |t|
      # user_id は null: false かつ一意 (ユニーク) に設定
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.string :access_token, null: false 
      t.string :refresh_token
      t.datetime :expires_at

      t.integer :followers_count, default: 0
      t.integer :public_repos_count, default: 0
      t.integer :total_private_repos_count, default: 0

      t.timestamps
    end
  end
end
