Rails.application.routes.draw do
  
  # ----------------------------------------------------
  #  Devise（認証機能）のルーティング定義を最優先
  # ----------------------------------------------------
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
    # パスワードリセット機能はDevise標準コントローラーが適用
  }

  # ----------------------------------------------------
  #  アプリケーションの中心機能のルーティング定義
  # ----------------------------------------------------
  
  # プロフィール表示 (show)、ユーザー一覧 (index)、
  # およびフレンド一覧 (/users/following) を追加
  resources :users, only: [:index, :show] do
    collection do
      get :following # GET /users/following => users#following
    end
  end
  
  # フォロー/アンフォロー
  resources :relationships, only: [:create, :destroy]

  # 評価（サンタ通知）
  resources :evaluations, only: [:index, :show, :new, :create]

  # --- ダッシュボード周りのルーティング ---
  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  # ----------------------------------------------------
  # 開発環境向けメール確認UIの追加
  # ----------------------------------------------------
  # Letter Opener Webを開発環境でのみ有効化し、本番環境へのアクセスを防止
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # ----------------------------------------------------
  # トップページ（Root Path）の定義
  # ----------------------------------------------------
  
  # 認証済みユーザー向けのルート
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # 未認証ユーザー向けのルート
  root to: redirect('/users/sign_in')
end
