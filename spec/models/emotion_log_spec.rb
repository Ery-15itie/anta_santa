require 'rails_helper'

RSpec.describe EmotionLog, type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    it 'メモ(body)が500文字以内なら有効' do
      log = build(:emotion_log, user: user, body: 'a' * 500)
      expect(log).to be_valid
    end
    
    # 他のバリデーションテストは省略（必要なら追加）
  end

  describe '.current_fire_state' do
    context 'ログがまだない場合' do
      it 'デフォルトの状態（36.5度）を返す' do
        state = EmotionLog.current_fire_state(user)
        # 36.5 と完全一致するか、誤差許容範囲で確認
        expect(state[:temperature]).to be_within(0.1).of(36.5)
      end
    end
  end
end
