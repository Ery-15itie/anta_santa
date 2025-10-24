Rails.application.routes.draw do
  
  # ----------------------------------------------------
  # 1. Devise（認証機能）のルーティング定義を最優先
  # ----------------------------------------------------
  # /users/sign_in, /users/sign_up, /users/sign_out などの基本ルートを定義
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # ----------------------------------------------------
  # 2. アプリケーションの中心機能のルーティング定義
  # ----------------------------------------------------
  
  # プロフィール表示 (show) とユーザー一覧 (index)
  resources :users, only: [:index, :show] 
  
  # フォロー/アンフォロー
  resources :relationships, only: [:create, :destroy]

  # 評価（サンタ通知）
  resources :evaluations, only: [:index, :show, :new, :create]

  # --- ダッシュボード周りのルーティング ---
  # GET /dashboard を dashboard#index に割り当てる
  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  # ----------------------------------------------------
  # 3. トップページ（Root Path）の定義
  # ----------------------------------------------------
  
  # 認証済みユーザー向けのルート（ログイン後のトップページ: /dashboardへリダイレクト）
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # 未認証ユーザー向けのルート（トップページアクセス時、ログイン画面へリダイレクト）
  root to: redirect('/users/sign_in')
end
