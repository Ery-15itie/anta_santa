class CreateJwtDenylists < ActiveRecord::Migration[7.2]
  def change
    # トークン失効リストテーブルを作成
    create_table :jwt_denylists do |t|
      t.string :jti, null: false # JWTのユニークID (必須)
      t.datetime :exp, null: false # トークンの有効期限 (必須)

      t.timestamps
    end
    # jtiにインデックスを追加し、検索を高速化
    add_index :jwt_denylists, :jti
  end
end
