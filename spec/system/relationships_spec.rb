require 'rails_helper'

RSpec.describe 'Relationships', type: :system do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    sign_in user
  end

  it 'ユーザーをフォローおよびフォロー解除できる', js: true do
    # ユーザー一覧画面へ移動
    visit users_path

    # --- フォローする ---
    # フォロー前の確認
    expect(page).to have_content('＋ フォロー', wait: 5)
    
    # ボタンをクリック (match: :first で最初の要素を確実に押す)
    click_on '＋ フォロー', match: :first

    # 【重要】処理完了待ち - 待機時間を延長
    # 画面の表示が「フォロー解除」に変わるのを待つことで、Ajax通信の完了を保証
    expect(page).to have_content('✔ フォロー解除', wait: 10)
    
    # さらに、DOM更新の完了を確実にするため、短い待機を追加
    sleep 0.5
    
    # DBのデータ確認
    # 【重要】user.reload をして、DBの最新状態を読み込み
    expect(user.reload.following?(other_user)).to be_truthy

    # --- フォロー解除する ---
    # 解除ボタンをクリック
    click_on '✔ フォロー解除', match: :first

    # 【重要】処理完了待ち - 待機時間を延長
    # 画面の表示が「＋ フォロー」に戻るのを待つ
    expect(page).to have_content('＋ フォロー', wait: 10)
    
    # さらに、DOM更新とDB反映の完了を確実にするため、短い待機を追加
    sleep 0.5
    
    # DBのデータ確認
    # ここも reload して確認
    expect(user.reload.following?(other_user)).to be_falsey
  end
end
