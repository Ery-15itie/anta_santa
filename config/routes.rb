Rails.application.routes.draw do
  # Deviseによるユーザー認証ルート
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # プロフィール表示とユーザー一覧 (index)
  # indexを追加することで、dashboardで必要とされる users_path が有効になる
  resources :users, only: [:index, :show] 
  
  # フォロー/アンフォロー
  resources :relationships, only: [:create, :destroy]

  # 評価（サンタ通知）
  resources :evaluations, only: [:index, :show, :new, :create]

  # --- ダッシュボード周りのルーティング ---
  # GET /dashboard を dashboard#index に割り当てる
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'

  # 認証済みユーザー向けのルート（ログイン後のトップページ）
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # 未認証ユーザー向けのルート（ログイン画面）
  root to: redirect('/users/sign_in')
end
