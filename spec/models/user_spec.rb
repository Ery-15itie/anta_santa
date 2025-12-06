require 'rails_helper'

RSpec.describe User, type: :model do
  # 感情の暖炉（連続記録）機能のロジック検証
  include ActiveSupport::Testing::TimeHelpers
  describe '#emotion_streak' do
    let(:user) { create(:user) }

    # テストデータ作成ヘルパー
    # days_ago: 何日前のログを作るか
    # count: その日に何回ログを作るか
    def create_log(days_ago, count: 1)
      count.times do
        # 日付計算の境界値ズレを防ぐため、常に「正午(12:00)」で作成して検証する
        create(:emotion_log, user: user, created_at: days_ago.days.ago.change(hour: 12))
      end
    end

    # テスト実行時の「現在時刻」を固定
    # これにより、深夜や月末などのタイミングによるテスト落ちを防ぐ
    around do |example|
      travel_to(Time.zone.parse('2024-01-10 12:00:00')) do
        example.run
      end
    end

    # --- ケース1: まだ薪をくべていない ---
    context '記録が全くない場合' do
      it '0を返すこと' do
        expect(user.emotion_streak).to eq 0
      end
    end

    # --- ケース2: 暖炉に火がついている状態（継続中） ---
    context '記録がある場合' do
      context '今日だけ記録している場合' do
        before { create_log(0) } # 今日
        it '継続日数: 1 を返すこと' do
          expect(user.emotion_streak).to eq 1
        end
      end

      # 【重要ロジック】今日はまだ書いていないが、昨日書いている場合
      context '昨日だけ記録している場合（今日はまだ）' do
        before { create_log(1) } # 昨日
        it '火はまだ消えていないとみなし、継続日数: 1 を返すこと' do
          # まだ今日の分を書いていなくても、昨日の分があればストリークは維持される仕様
          expect(user.emotion_streak).to eq 1
        end
      end

      context '昨日と今日、連続で記録している場合' do
        before do
          create_log(1) # 昨日
          create_log(0) # 今日
        end
        it '継続日数: 2 を返すこと' do
          expect(user.emotion_streak).to eq 2
        end
      end

      context '3日連続で記録している場合' do
        before do
          create_log(2)
          create_log(1)
          create_log(0)
        end
        it '継続日数: 3 を返すこと' do
          expect(user.emotion_streak).to eq 3
        end
      end

      # 【ロジック確認】1日に何度も薪をくべた場合
      context '1日に複数回記録した場合' do
        before do
          create_log(1, count: 3) # 昨日3回
          create_log(0, count: 2) # 今日2回
        end
        it '回数ではなく「ユニークな日付」でカウントし、継続日数: 2 を返すこと' do
          expect(user.emotion_streak).to eq 2
        end
      end

      # --- ケース3: 火が途切れてしまった場合 ---
      context '記録が途切れている場合' do
        before do
          create_log(0) # 今日
          create_log(1) # 昨日
          # --- ここで1日空く（2日前はサボり） ---
          create_log(3) # 3日前
          create_log(4) # 4日前
        end
        it '過去の記録は無視し、直近の連続日数（2）のみを返すこと' do
          expect(user.emotion_streak).to eq 2
        end
      end

      context '一昨日まで連続記録し、昨日・今日サボった場合' do
        before do
          create_log(2) # 2日前
          create_log(3) # 3日前
        end
        it '火が完全に消えていると判定し、0を返すこと' do
          # 昨日の記録がない時点でストリークはゼロになる
          expect(user.emotion_streak).to eq 0
        end
      end
    end
  end
end
  # 他のUserモデルのテストコードは省略
