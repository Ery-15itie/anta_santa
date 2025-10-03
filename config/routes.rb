Rails.application.routes.draw do
  # Sidekiq Web UI (開発/管理者用) - ログインユーザーのみアクセス可能
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.persisted? } do 
    mount Sidekiq::Web => '/sidekiq'
  end

  # 認証ルーティング:有効化
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'devise/sessions', 
    registrations: 'devise/registrations' 
  }

  # ログイン後のルート
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  # 未ログイン時のルート
  root to: "home#index" 

  # ソーシャル機能
  resources :users, only: [:show, :edit, :update] do
    resource :relationships, only: [:create, :destroy]
  end
  resources :groups

  # コア機能
  resources :templates 
  resources :evaluations 

  # レポート・統計
  resources :reports, only: [:index, :show]

  # その他
  resource :github_integration, only: [:show, :create] 
end
