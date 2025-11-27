require 'rails_helper'

RSpec.describe 'EmotionHearth (感情の暖炉)', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit root_path
    # Reactの描画待ち (Heartory Homeが表示されるまで待つ)
    expect(page).to have_content('Heartory Home', wait: 10)
  end

  it 'ポジティブな感情を薪としてくべることができる', js: true do
    # 1. 暖炉の部屋へ移動
    find('h4', text: '🔥 暖炉のリビング').click
    
    # 画面遷移確認
    expect(page).to have_content 'TEMP:' 
    expect(page).to have_content '今の気持ちを選んでください'

    # 2. 感情を選択
    find('button', text: '😊 嬉しい', match: :first).click

    # 3. 強さを選択
    find('div, span, button, li', text: /^3$/, match: :first).click

    # 4. メモ入力
    find('input[placeholder*="その気持ちについて"]').set('テストの薪です')

    # 5. 「薪をくべる」ボタンをクリック
    click_on '薪をくべる 🔥'

    # 6. 【待機】処理中メッセージが表示され、消えるのを確実に待つ
    # これによりアニメーション完了までテストを待機させる
    expect(page).to have_no_content('燃やしています...', wait: 10)

    # 7. 成功メッセージの確認
    expect(page).to have_content('感情が炎に変わりました', wait: 10)
    
    # 8. タイムラインに追加されたか確認
    expect(page).to have_selector('*', text: 'テストの薪です', visible: false)
  end

  it 'ネガティブな感情に魔法の粉を使ってくべる', js: true do
    find('h4', text: '🔥 暖炉のリビング').click

    # 1. ネガティブ感情を選択
    find('button', text: '😔 悲しい', match: :first).click
    
    # 2. 強さを選択
    find('div, span, button, li', text: /^3$/, match: :first).click

    # 3. 「薪をくべる」
    click_on '薪をくべる 🔥'

    # 4. モーダル確認
    expect(page).to have_content '魔法の粉を使いますか？'

    # 5. 魔法の粉を選択
    find('button', text: '銅の粉 (青緑)').click

    # 6. 【待機】モーダルや処理中メッセージが消えるのを待つ
    expect(page).to have_no_content('魔法の粉を使いますか？', wait: 10)
    
    # もし粉選択後にも「燃やしています...」が出る仕様なら、それも待つ
    if page.has_content?('燃やしています...')
      expect(page).to have_no_content('燃やしています...', wait: 10)
    end

    # 7. 成功確認
    expect(page).to have_content('感情が炎に変わりました', wait: 10)
  end

  it '統計画面（ログ）に移動できる', js: true do
    find('h4', text: '🔥 暖炉のリビング').click

    # LOGボタンをクリック
    find('span', text: 'LOG').click

    # 統計画面の確認
    expect(page).to have_content '灯火のあしあと'
    expect(page).to have_content 'KEEPER TITLE'
  end
end
