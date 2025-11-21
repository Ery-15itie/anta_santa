Rails.application.routes.draw do
  
  # ----------------------------------------------------
  #  1. Devise（認証機能）- 既存のまま維持
  # ----------------------------------------------------
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # ----------------------------------------------------
  #  2. API v1 エンドポイント (NEW: React連携用)
  # ----------------------------------------------------
  # Heartory Home (React) がデータを取得するための窓口
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # 暖炉の部屋（感情ログ）用
      resources :emotion_logs, only: [:index, :create, :show, :update, :destroy]
      
      # ※ 必要に応じて将来ここへ users や evaluations のAPIも追加可能
    end
  end

  # ----------------------------------------------------
  #  3. ルーティングのメイン定義
  # ----------------------------------------------------
  
  # === ログイン済みユーザーの世界 ===
  authenticated :user do
    # 【A】新しい玄関: Heartory Home (Reactダッシュボード)
    # 新しく作る HomesController がここを担当
    root 'homes#index', as: :authenticated_root

    # 【B】既存のダッシュボード: 🎁 ギフトホール
    # 今まで root だった dashboard#index を、ここに引っ越し
    # URLは '/gift-hall' になりますが、中身は既存のまま
    get 'gift-hall', to: 'dashboard#index', as: :gift_hall
    
    # ※念のため既存の /dashboard というURLも残しておく
    get 'dashboard', to: 'dashboard#index'
  end

  # === 未ログインユーザーの世界 ===
  devise_scope :user do
    # ログインしていない人は、既存のログイン画面へ
    root to: redirect('/users/sign_in')
  end

  # ----------------------------------------------------
  #  4. アプリケーションの既存機能 (変更なし)
  # ----------------------------------------------------
  # これらは「ギフトホール」の中で動く機能としてそのまま維持
  resources :users, only: [:index, :show] do
    collection do
      get :following
    end
  end
  
  resources :relationships, only: [:create, :destroy]
  resources :evaluations, only: [:index, :show, :new, :create]

  # ----------------------------------------------------
  #  5. 開発ツール
  # ----------------------------------------------------
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
