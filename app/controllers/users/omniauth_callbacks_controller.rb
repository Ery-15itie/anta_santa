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
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      session['devise.github_data'] = auth.except('extra')
      redirect_to new_user_registration_url, alert: 'GitHub認証に失敗しました。'
    end
  rescue => e
    Rails.logger.error "GitHub認証エラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path, alert: 'GitHub認証中にエラーが発生しました。'
  end

  # =================================================================
  # 2. Google認証 (ログイン・新規登録・連携の全対応)
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
        # ※providerとuidを更新して紐付け
        current_user.update(provider: auth.provider, uid: auth.uid)
        
        # 画面にメッセージを出して元の場所へ戻る
        redirect_to root_path, notice: 'Googleアカウントと連携しました！'
      end

    # 【パターンB: ログインしていない場合 (ログイン画面/新規登録画面からのアクセス)】
    else
      # User.from_omniauth は「なければ作成(first_or_create)」するように修正済み
      @user = User.from_omniauth(auth)

      if @user.persisted?
        # ユーザー作成・検索に成功 → ログイン
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      else
        # 作成に失敗した場合（例: 同じメアドが既にパスワード登録で存在するなど）
        # 失敗理由を画面に表示するため、新規登録画面へリダイレクト
        session['devise.google_data'] = auth.except('extra')
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
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
    # user.github_profile がnilの場合に備えて build する
    github_profile = user.github_profile || user.build_github_profile
    
    # extra.raw_info が存在するか安全にチェックしつつ代入
    raw_info = auth.extra.raw_info || {}

    github_profile.assign_attributes(
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil,
      followers_count: raw_info.followers || 0,
      public_repos_count: raw_info.public_repos || 0,
      total_private_repos_count: raw_info.total_private_repos || 0
    )
    
    github_profile.save
  end
end
