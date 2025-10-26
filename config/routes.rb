Rails.application.routes.draw do
  
  # ----------------------------------------------------
  #  Devise（認証機能）のルーティング定義を最優先
  # ----------------------------------------------------
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
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
  # トップページ（Root Path）の定義
  # ----------------------------------------------------
  
  # 認証済みユーザー向けのルート
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # 未認証ユーザー向けのルート
  root to: redirect('/users/sign_in')
end
