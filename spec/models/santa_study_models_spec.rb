require 'rails_helper'

RSpec.describe "SantaStudy Models", type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe 'UserCardSelection (価値観パズル)' do
    let(:card) { FactoryBot.create(:value_card) }

    context '正常系' do
      it 'ユーザー、カード、時間軸があれば有効であること' do
        selection = UserCardSelection.new(user: user, value_card: card, timeframe: 'current')
        expect(selection).to be_valid
      end
    end

    context 'ユニーク制約' do
      before { UserCardSelection.create(user: user, value_card: card, timeframe: 'current') }

      it '同じ時間軸で同じカードを重複して登録できないこと' do
        duplicate = UserCardSelection.new(user: user, value_card: card, timeframe: 'current')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:value_card_id]).to be_present
      end

      it '異なる時間軸なら同じカードを登録できること' do
        future_selection = UserCardSelection.new(user: user, value_card: card, timeframe: 'future')
        expect(future_selection).to be_valid
      end
    end
  end

  describe 'UserReflection (航海日誌)' do
    let(:question) { FactoryBot.create(:reflection_question) }

    context '正常系' do
      it 'ユーザー、質問、回答があれば有効であること' do
        reflection = UserReflection.new(user: user, reflection_question: question, answer: "テスト回答")
        expect(reflection).to be_valid
      end
    end

    context 'ユニーク制約' do
      before { UserReflection.create(user: user, reflection_question: question, answer: "最初の回答") }

      it '1つの質問に対して重複して回答レコードを作成できないこと' do
        duplicate = UserReflection.new(user: user, reflection_question: question, answer: "二回目の回答")
        expect(duplicate).not_to be_valid
      end
    end
  end
end
