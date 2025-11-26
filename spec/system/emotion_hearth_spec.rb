require 'rails_helper'

RSpec.describe 'EmotionHearth (感情の暖炉)', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit root_path
    expect(page).to have_content('Heartory Home', wait: 10)
  end

  it 'ポジティブな感情を薪としてくべることができる', js: true do
    find('h4', text: '🔥 暖炉のリビング').click
    
    # 画面遷移確認: "TEMP:" は確実に表示されているはず
    expect(page).to have_content 'TEMP:'
    expect(page).to have_content '今の気持ちを選んでください'

    # 感情選択
    find('button', text: '😊 嬉しい').click

    # メモ入力
    find('input[placeholder*="その気持ちについて"]').set('テストの薪です')

    # 送信
    click_on '薪をくべる 🔥'

    # 成功確認
    expect(page).to have_content '感情が炎に変わりました'
    expect(page).to have_content('Today\'s Logs') 
  end

  it 'ネガティブな感情に魔法の粉を使ってくべる', js: true do
    find('h4', text: '🔥 暖炉のリビング').click

    find('button', text: '😔 悲しい').click
    click_on '薪をくべる 🔥'

    expect(page).to have_content '魔法の粉を使いますか？'

    find('button', text: '銅の粉 (青緑)').click

    expect(page).to have_content '感情が炎に変わりました'
  end

  it '統計画面（ログ）に移動できる', js: true do
    find('h4', text: '🔥 暖炉のリビング').click

    # ▼▼▼ LOGボタンを特定する ▼▼▼
    # "LOG" という文字を持つ要素の中で、ヘッダー内にあるものをクリック
    # または spanタグを狙い撃ちする
    find('span', text: 'LOG').click

    # 画面遷移確認
    expect(page).to have_content '灯火のあしあと'
    expect(page).to have_content 'KEEPER TITLE'
    expect(page).to have_content 'LEVEL'
  end
end
