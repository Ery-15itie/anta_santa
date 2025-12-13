class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # GitHubだけでなく、Google認証時もCSRF保護をスキップする必要がある
  skip_before_action :verify_authenticity_token, only: [:github, :google_oauth2]

  # =================================================================
  # 1. GitHub認証 (既存のコードを維持)
  # =================================================================
  def github
    auth = request.env['omniauth.auth']
    # 注意: Userモデルに self.from_omniauth が実装されている前提
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
  # 2. Google認証 
  # =================================================================
  def google_oauth2
    # まずは「接続テスト」として、Googleから届いた情報を画面に表示します。
    # これが表示されれば、通信設定は100%成功です。
    auth = request.env['omniauth.auth']
    render plain: "Google連携成功！\n\n取得データ: #{auth.inspect}"
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
