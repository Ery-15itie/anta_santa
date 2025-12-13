class AddRescueCodeToUsers < ActiveRecord::Migration[7.2]
  def change
    # 救済コード（ランダム文字列）
    add_column :users, :rescue_code, :string
    # 有効期限
    add_column :users, :rescue_code_expires_at, :datetime
    
    # 高速検索と重複防止のインデックス
    add_index :users, :rescue_code, unique: true
  end
end