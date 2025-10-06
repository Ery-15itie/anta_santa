Rails.application.routes.draw do
  # Devise (GitHub OmniAuth) のルーティング
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # ログイン後のリダイレクト先
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # トップページ (未認証ユーザー)
  root 'home#index'

  # ダッシュボード
  get 'dashboard', to: 'dashboard#index'

  # ユーザープロフィール
  resources :users, only: [:show, :edit, :update] do
    member do
      get :followers
      get :following
    end
  end

  # フォロー機能
  resources :relationships, only: [:create, :destroy]

  # テンプレート管理
  resources :templates do
    member do
      post :duplicate
    end
    resources :template_items, only: [:create, :update, :destroy]
  end

  # 評価機能
  resources :evaluations do
    member do
      patch :submit
      patch :publish
    end
    resources :evaluation_scores, only: [:create, :update]
  end

  # レポート
  resources :reports, only: [:index, :show]

  # グループ
  resources :groups do
    member do
      post :join
      delete :leave
    end
    resources :group_memberships, only: [:create, :destroy]
  end

  # GitHub連携
  namespace :github do
    get 'connect', to: 'integration#connect'
    delete 'disconnect', to: 'integration#disconnect'
    post 'sync', to: 'integration#sync'
  end

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # API (将来的な拡張用)
  namespace :api do
    namespace :v1 do
      resources :evaluations, only: [:index, :show]
      resources :github_stats, only: [:index]
    end
  end
end
