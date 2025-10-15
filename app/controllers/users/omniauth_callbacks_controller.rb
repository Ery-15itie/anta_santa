class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)

    if @user.persisted?
      # GitHubプロフィール情報を保存/更新
      create_or_update_github_profile(@user, auth)
      
      sign_in_and_redirect @user, event: :authentication
      # 直接日本語メッセージを設定（set_flash_messageではなくflashに直接代入）
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

  def failure
    redirect_to root_path, alert: 'GitHub認証に失敗しました。もう一度お試しください。'
  end

  private

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
