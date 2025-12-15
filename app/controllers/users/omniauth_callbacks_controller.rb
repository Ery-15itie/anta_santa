class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # GitHub、Google認証時CSRF保護をスキップ
  skip_before_action :verify_authenticity_token, only: [:github, :google_oauth2]

  # =================================================================
  # 1. GitHub認証 (既存のコードを維持)
  # =================================================================
  def github
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)

    if @user.persisted?
      # GitHubプロフィール情報を保存/更新
      create_or_update_github_profile(@user, auth)
      
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = 'GitHubアカウントと連携し、ログインしました。'
    else
      session['devise.github_data'] = auth.except('extra')
      redirect_to new_user_registration_url, alert: '認証に失敗しました。'
    end
  rescue => e
    Rails.logger.error "GitHub認証エラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path, alert: 'GitHub認証中にエラーが発生しました。'
  end

  # =================================================================
  # 2. Google認証 ( ログインと連携の両対応)
  # =================================================================
  def google_oauth2
    auth = request.env['omniauth.auth']

    # 【パターンA: 既にログインしている場合 (プロフィール設定からの連携)】
    if user_signed_in?
      # 1. そのGoogleアカウントが既に他の誰かに使われていないかチェック
      if User.exists?(provider: auth.provider, uid: auth.uid)
        redirect_to root_path, alert: 'このGoogleアカウントは既に他のユーザーに使用されています。'
      else
        # 2. 現在のユーザーに紐付け（連携）
        current_user.update(provider: auth.provider, uid: auth.uid)
        redirect_to root_path, notice: 'Googleアカウントと連携しました！'
      end

    # 【パターンB: ログインしていない場合 (ログイン画面からのサインイン)】
    else
      # Userモデルの from_omniauth でユーザーを探す（または作る）
      @user = User.from_omniauth(auth)

      if @user&.persisted?
        # ログイン成功
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      else
        # ユーザーが見つからない/作れない場合
        session['devise.google_data'] = auth.except('extra')
        # 新規登録画面ではなくログイン画面に戻すのが一般的（アカウントがない旨を伝える）
        redirect_to new_user_session_url, alert: 'アカウントが見つかりません。'
      end
    end
  end

  # =================================================================
  # 3. 共通処理
  # =================================================================
  def failure
    redirect_to root_path, alert: '認証に失敗しました。もう一度お試しください。'
  end

  private

  # GitHub用のプロフィール保存処理 (既存のまま)
  def create_or_update_github_profile(user, auth)
    github_profile = user.github_profile || user.build_github_profile
    
    github_profile.assign_attributes(
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil,
      followers_count: auth.extra.raw_info.followers || 0,
      public_repos_count: auth.extra.raw_info.public_repos || 0,
      total_private_repos_count: auth.extra.raw_info.total_private_repos || 0
    )
    
    github_profile.save
  end
end
