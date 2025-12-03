require 'rails_helper'

RSpec.describe "Evaluations", type: :system, js: true do
  let(:user) { FactoryBot.create(:user) }
  let!(:other_user) { User.find_by(username: 'テストユーザー2') }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    find('input[type="submit"]').click
  end

  it '相手を選んで感謝の手紙を送ることができる' do
    visit gift_hall_path
    click_link 'メッセージを送る'
    
    # ユーザー一覧からテストユーザー2を選択
    user_card = find('div.flex', text: 'テストユーザー2', match: :first)
    within(user_card) do
      click_link 'お手紙を送る'
    end

    # フォームが表示されたことを確認
    expect(page).to have_button('送信')
    
    # 任意の項目をチェック（最初の項目）
    first('input[type="checkbox"]').click
    fill_in 'evaluation[message]', with: 'テストメッセージ'
    click_button '送信'

    # 送信完了
    expect(page).not_to have_button('送信')
  end
end
