Rails.application.routes.draw do
  
  # ----------------------------------------------------
  #  1. Devise（認証機能）
  # ----------------------------------------------------
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # ----------------------------------------------------
  #  2. 静的ページ (村の公共施設) - 未ログインでもアクセス可
  # ----------------------------------------------------
  # これにより terms_path, privacy_path, contact_path が使えるようになります
  get 'guide',    to: 'pages#guide',    as: :guide    # 操作ガイド
  get 'terms',    to: 'pages#terms',    as: :terms    # 利用規約
  get 'privacy',  to: 'pages#privacy',  as: :privacy  # プライバシーポリシー
  get 'contact',  to: 'pages#contact',  as: :contact  # お問い合わせ

  # ----------------------------------------------------
  #  3. API v1 エンドポイント (React連携用)
  # ----------------------------------------------------
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # 暖炉の部屋（感情ログ）
      resources :emotion_logs, only: [:index, :create] do
        # 統計・実績データを取得するエンドポイント
        collection do
          get :stats
        end
      end
    end
  end

  # ----------------------------------------------------
  #  4. ルーティングのメイン定義
  # ----------------------------------------------------
  
  # === ログイン済みユーザーの世界 ===
  authenticated :user do
    # 【A】新しい玄関: Heartory Home (Reactダッシュボード)
    root 'homes#index', as: :authenticated_root

    # Reactのページでリロードしても404にならないようにする設定
    # これらのURLにアクセスが来たら、Reactの入り口(homes#index)を表示させます
    get 'emotion-log',    to: 'homes#index'
    get 'emotion-stats',  to: 'homes#index'
    get 'santa-study',    to: 'homes#index'     # 将来用
    get 'atelier',        to: 'homes#index'     # 将来用
    get 'kitchen',        to: 'homes#index'     # 将来用
    get 'planning',       to: 'homes#index'     # 将来用
    get 'reindeer',       to: 'homes#index'     # 将来用
    get 'gallery',        to: 'homes#index'     # 将来用
    get 'gallery-detail', to: 'homes#index'     # 将来用
    get 'basement',       to: 'homes#index'     # 将来用

    # 【B】既存のダッシュボード: 🎁 ギフトホール
    get 'gift-hall', to: 'dashboard#index', as: :gift_hall
    
    # 既存互換用
    get 'dashboard', to: 'dashboard#index'
  end

  # === 未ログインユーザーの世界 ===
  devise_scope :user do
    # ログインしていない人は、ログイン画面へ
    root to: redirect('/users/sign_in')
  end

  # ----------------------------------------------------
  #  5. アプリケーションの既存機能 (Rails View)
  # ----------------------------------------------------
  resources :users, only: [:index, :show] do
    collection do
      get :following
    end
  end
  
  resources :relationships, only: [:create, :destroy]
  resources :evaluations, only: [:index, :show, :new, :create]

  # ----------------------------------------------------
  #  6. 開発ツール
  # ----------------------------------------------------
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
