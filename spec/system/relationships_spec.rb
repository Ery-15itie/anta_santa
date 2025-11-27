require 'rails_helper'

RSpec.describe 'Relationships', type: :system do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    sign_in user
  end

  it 'ユーザーをフォローおよびフォロー解除できる', js: true do
    visit users_path

    # ▼▼▼ buttonタグに限定せず、表示テキストでクリックする ▼▼▼
    # デザイン変更でボタンが button タグでない場合や、アイコンを含む場合に備えて
    
    # フォロー前
    expect(page).to have_content '＋ フォロー'
    click_on '＋ フォロー' , match: :first # click_button ではなく click_on を使用

    # フォロー後（AjaxやTurboの完了を待つため、have_contentで確認）
    expect(page).to have_content '✔ フォロー解除'
    
    # データ確認
    expect(user.following?(other_user)).to be_truthy

    # 解除実行
    click_on '✔ フォロー解除'

    # 解除後
    expect(page).to have_content '＋ フォロー'
    expect(user.following?(other_user)).to be_falsey
  end
end
