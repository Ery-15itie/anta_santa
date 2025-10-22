class AddTrackableToUsers < ActiveRecord::Migration[7.2]
  def change
    ## Trackable
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
    
    # 既存ユーザーにデフォルト値を設定
    User.update_all(sign_in_count: 0) if defined?(User)
  end
end
