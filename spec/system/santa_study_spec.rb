require 'rails_helper'

RSpec.describe "Santa's Study Functionality", type: :system, js: true do
  let(:user) { FactoryBot.create(:user) }
  
  before do
    # 画面サイズをPCサイズに広げる
    Capybara.current_session.driver.browser.manage.window.resize_to(1280, 800)

    # データをリセット
    UserCardSelection.delete_all
    UserReflection.delete_all
    ValueCard.delete_all
    ValueCategory.delete_all
    ReflectionQuestion.delete_all

    # パズル用データ
    category = FactoryBot.create(:value_category, name: '学びの雲')
    @card1 = FactoryBot.create(:value_card, name: 'テスト用好奇心', value_category: category, description: 'テスト用の説明文です')
    @card2 = FactoryBot.create(:value_card, name: 'テスト用挑戦', value_category: category)
    
    # 航海日誌用データ
    @question1 = FactoryBot.create(:reflection_question, body: '一番楽しかった思い出は？', position: 1)
    @question2 = FactoryBot.create(:reflection_question, body: '未来の夢は？', position: 2)

    # ログイン処理
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    find('input[type="submit"]').click
  end

  it '書斎に入り、価値観パズルと航海日誌を利用できる' do
    # 1. ホーム画面からサンタの書斎へ移動
    expect(page).to have_content('Heartory Home')
    find('h4', text: 'サンタの書斎').find(:xpath, '../../..').click

    # 書斎の部屋（メニュー）
    expect(page).to have_content('価値観の地図')
    expect(page).to have_content('心の航海日誌')

    # --- 価値観パズルのテスト ---
    find('button', text: '価値観の地図').click

    # 星空画面
    expect(page).to have_content('学びの雲')
    
    # 星（カード）を選択
    find('button', text: 'テスト用好奇心', match: :first).click
    
    # 詳細モーダルで登録
    expect(page).to have_content('テスト用の説明文です')
    click_button 'この価値観を星として登録する'

    # 選択数が増えているか確認
    expect(page).to have_content(/Stars:.*1.*\/.*10/)

    # 決定して保存
    click_button '決定して振り返る'
    
    # 振り返り入力モーダル
    expect(page).to have_content('航海日誌')
    find('textarea[placeholder*="ここに想いを書き留めてください"]').set('新しいことを知るのが好きだから')
    
    click_button '記録を保存する'

    # 保存完了通知
    expect(page).to have_content('航海日誌に記録しました')
    
    # 部屋に戻る
    find('header button', match: :first).click

    # --- 心の航海日誌のテスト ---
    expect(page).to have_content('心の航海日誌')
    find('button', text: '心の航海日誌').click

    # 本が開く
    expect(page).to have_content('一番楽しかった思い出は？')
    find('textarea').set('遊園地に行ったこと')
    
    # 次のページへ
    find('button svg.lucide-chevron-right').find(:xpath, '..').click
    expect(page).to have_content('未来の夢は？')

    # 閉じる
    find('button svg.lucide-x').find(:xpath, '..').click

    # ▼▼▼ 閉じたことを確実に待つ▼▼▼
    # テキストエリアが画面から消えるまで待機してから次へ進む
    expect(page).to have_no_selector('textarea')

    # 再度開いて保存確認
    find('button', text: '心の航海日誌').click
    expect(page).to have_content('一番楽しかった思い出は？')

    # テキストエリアに特定の値が入っていることを確認
    expect(page).to have_field(with: '遊園地に行ったこと')
  end
end
