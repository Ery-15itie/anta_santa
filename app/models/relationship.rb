class Relationship < ApplicationRecord
  # フォロワー (自分)
  belongs_to :follower, class_name: 'User', foreign_key: 'follower_id'
  # フォロー対象 (相手)
  belongs_to :followed, class_name: 'User', foreign_key: 'followed_id'

  # バリデーション
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  # 同じユーザーが同じユーザーを二度フォローできないようにする
  validates :follower_id, uniqueness: { scope: :followed_id }
end
