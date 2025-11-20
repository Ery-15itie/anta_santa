class Notification < ApplicationRecord
  # 受信者 (通知を受け取るユーザー: recipient_id)
  belongs_to :recipient, class_name: 'User'
  # 通知を起こした人 (例: 評価者、フォローした人: actor_id)
  belongs_to :actor, class_name: 'User'
  
  # 通知対象のポリモーフィック関連付け (例: Evaluation, Relationshipなど)
  # これにより、1つの通知モデルで様々な種類のオブジェクトの通知を扱える
  belongs_to :notifiable, polymorphic: true

  # スコープ: 未読の通知を簡単に取得できるようにする
  scope :unread, -> { where(read_at: nil) }
  
  # バリデーション
  validates :recipient_id, presence: true
  validates :actor_id, presence: true
  validates :notifiable_type, presence: true
  validates :notifiable_id, presence: true
end
