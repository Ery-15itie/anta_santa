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
        collection do
          get :stats
        end
      end

      #  サンタの書斎 (価値観パズル) 機能 
      # パズル一覧取得用
      resources :value_categories, only: [:index]
      # ユーザーの選択保存・削除用
      resources :user_card_selections, only: [:index, :create, :destroy]
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
    # これにより、/santa-study でリロードしても homes#index が呼ばれ、Reactが起動する
    get 'emotion-log',    to: 'homes#index'
    get 'emotion-stats',  to: 'homes#index'
    get 'santa-study',    to: 'homes#index'     # 価値観パズル
    
    # --- 以下、将来実装予定のページのプレースホルダー ---
    get 'atelier',        to: 'homes#index'
    get 'kitchen',        to: 'homes#index'
    get 'planning',       to: 'homes#index'
    get 'reindeer',       to: 'homes#index'
    get 'gallery',        to: 'homes#index'
    get 'gallery-detail', to: 'homes#index'
    get 'basement',       to: 'homes#index'

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
