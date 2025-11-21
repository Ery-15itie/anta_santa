require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  let(:user) { create(:user) }

  before do
    create(:template)
  end

  context 'ログイン処理' do
    it '正しい情報でログインし、Heartory Homeが表示されること', js: true do
      visit new_user_session_path

      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: user.password
      
      # ログインボタンをクリック
      click_button 'ログイン'

      # Reactがマウントされる要素が現れるまで待機（最大10秒）
      expect(page).to have_css('#heartory-home-root', visible: false, wait: 10)
      
      # その後、URLを確認
      expect(current_path).to eq root_path
      
      # 画面内のテキスト確認
      expect(page).to have_content 'Heartory Home'
      expect(page).to have_content 'EXIT'
    end

    it '誤った情報ではログインできないこと' do
      visit new_user_session_path
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrong_password'
      click_button 'ログイン'

      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
    end
  end
end
