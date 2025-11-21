require 'rails_helper'

RSpec.describe 'Evaluations', type: :system do
  let(:sender) { create(:user, username: 'SenderSanta') }
  let!(:receiver) { create(:user, username: 'ReceiverSanta') }
  let!(:template) { create(:template) }

  before do
    sign_in sender
  end

  it '相手を選んで感謝の手紙を送り、送信トレイで確認できる', js: true do
    # 1. ユーザー一覧へ
    visit users_path
    
    # 相手ユーザーがいるか確認
    expect(page).to have_content receiver.username

    # 2. 「お手紙を送る」ボタンをクリック
    click_on 'お手紙を送る', match: :first

    # 3. 手紙作成画面
    expect(page).to have_content "To: #{receiver.username}"
    
    # 入力
    fill_in 'evaluation[message]', with: 'いつもありがとう！'
    check '行動力がすごい'

    # 4. 送信ボタンをクリック
    # デザイン変更で装飾されていても、buttonタグやinput[type=submit]のvalueが「送信」なら反応します
    click_button '送信'

    # 5. 送信完了 (一覧画面へ遷移するまで待つ)
    expect(page).to have_content 'MY MAILBOX'
    expect(page).to have_content 'お手紙を「ReceiverSanta」さんに送りました。'
    
    # 6. 送信トレイを確認
    click_link '送った手紙'

    # 内容が表示されているか
    expect(page).to have_content receiver.username
    expect(page).to have_content 'いつもありがとう！'
  end
end
