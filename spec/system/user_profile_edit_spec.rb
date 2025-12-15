require 'rails_helper'

RSpec.describe 'プロフィール編集機能', type: :system, js: true do
  # password_confirmation も忘れずに指定
  let(:user) { create(:user, public_id: 'old_id', password: 'password123', password_confirmation: 'password123') }

  before do
    # 1. ログインページへ移動
    visit new_user_session_path

    # 2. ログイン情報を入力
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    
    # 3. ログインボタンをクリック
    click_button '扉を開ける (ログイン)'

    # 4. ログイン完了を待機
    expect(page).to have_content 'ログインしました' 

    # 5. プロフィール編集ページへ移動
    visit edit_user_registration_path 
  end

  describe '公開IDの変更' do
    context '正しい値を入力した場合' do
      it '公開IDが更新されること' do
        # 画面が表示されているか確認
        expect(page).to have_field '公開ID'

        # 新しいIDと現在のパスワードを入力
        fill_in '公開ID', with: 'new_awesome_id'
        fill_in '現在のパスワード', with: 'password123'

        # 保存ボタンをクリック（Viewファイルのボタン名と一致させる）
        click_button '変更を保存する'

        # 成功メッセージとDBの更新を確認
        expect(page).to have_content 'アカウント情報を変更しました'
        expect(user.reload.public_id).to eq 'new_awesome_id'
      end
    end

    context '重複するIDを入力した場合' do
      let!(:other_user) { create(:user, public_id: 'taken_id') }

      it 'エラーが表示され更新されないこと' do
        # 画面表示待機
        expect(page).to have_field '公開ID'
        
        fill_in '公開ID', with: 'taken_id'
        fill_in '現在のパスワード', with: 'password123'
        click_button '変更を保存する'

        expect(page).to have_content '公開IDはすでに存在します'
        # 更新されていないことを確認
        expect(user.reload.public_id).to eq 'old_id'
      end
    end

    context '現在のパスワードを入力しなかった場合' do
      it 'エラーが表示され更新されないこと' do
        # 画面表示待機
        expect(page).to have_field '公開ID'

        fill_in '公開ID', with: 'no_pass_id'
        # パスワード入力なしで保存
        click_button '変更を保存する'

        expect(page).to have_content '現在のパスワードを入力してください'
        # 更新されていないことを確認
        expect(user.reload.public_id).to eq 'old_id'
      end
    end
  end
end
