class OgpImage < ApplicationRecord
  # ActiveStorageで画像を紐付け
  has_one_attached :image

  # 保存前にランダムなID(uuid)を生成
  before_create :set_uuid

  # URLのパラメータとしてIDの代わりにUUIDを使う設定
  def to_param
    uuid
  end

  private

  def set_uuid
    self.uuid = SecureRandom.urlsafe_base64(10)
  end
end
