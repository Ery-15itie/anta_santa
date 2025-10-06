class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # GitHub認証が成功した場合に Devise から呼び出されるメソッド
  def github
    # 1. ユーザーの検索または作成
    # User.from_omniauth メソッドは User モデルで定義が必要
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # 2. 永続化（データベースに保存）に成功した場合、ログイン処理を行う
      sign_in_and_redirect @user, event: :authentication # この行でログインが完了
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      # 3. ユーザーの作成/保存に失敗した場合
      # 例: バリデーションエラーなどで保存できなかった場合、ユーザー情報をセッションに保存してサインアップ画面にリダイレクト
      session["devise.github_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  # 認証に失敗した場合（Callback URLの不一致など）にDeviseから呼び出される
  def failure
    redirect_to root_path
  end
end
