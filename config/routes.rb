Rails.application.routes.draw do
  
  # ----------------------------------------------------
  #  1. Devise（認証機能）
  # ----------------------------------------------------
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks' 
  }

  # ----------------------------------------------------
  #  2. 静的ページ
  # ----------------------------------------------------
  get 'guide',    to: 'pages#guide',    as: :guide    # 操作ガイド
  get 'terms',    to: 'pages#terms',    as: :terms    # 利用規約
  get 'privacy',  to: 'pages#privacy',  as: :privacy  # プライバシーポリシー
  get 'contact',  to: 'pages#contact',  as: :contact  # お問い合わせ

  # 管理者用救済パネル表示ページ (ログイン必須)
  get 'admin',    to: 'pages#admin',    as: :admin

  # ----------------------------------------------------
  #  2.5 共有ページ（OGP画像表示用）- 未ログインでもアクセス可
  # ----------------------------------------------------
  get 'share/:id', to: 'share#show', as: :share

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

      # サンタの書斎 (価値観パズル) 機能 
      resources :value_categories, only: [:index]
      resources :user_card_selections, only: [:index, :create, :destroy]
      
      # 航海日誌 (魔法の本) 機能
      resources :reflections, only: [:index, :update]
      
      # OGP画像アップロード用
      resources :ogp_images, only: [:create]

      # ==========================================
      # 引継ぎ・救済機能用エンドポイント
      # ==========================================
      # 1. 救済コード認証 (ログインできないユーザー向け)
      resource :rescue_session, only: [:create]

      # 2. ソーシャル連携 (ログイン中のユーザー向け)
      resource :social_provider, only: [:create, :destroy]

      # 管理者専用APIエリア
      namespace :admin do
        # 救済コード発行API
        resources :rescue_codes, only: [:create]
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
    get 'emotion-log',    to: 'homes#index'
    get 'emotion-stats',  to: 'homes#index'
    get 'santa-study',    to: 'homes#index'     
    
    # --- 将来実装予定のページのプレースホルダー ---
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
