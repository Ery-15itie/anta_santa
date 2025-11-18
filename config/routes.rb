Rails.application.routes.draw do
  
  # =========================================================
  # 認証ルート (Devise & JWT)
  # =========================================================
  devise_for :users, path: 'api/v1/auth', defaults: { format: :json }, 
             controllers: {
               sessions: 'api/v1/sessions',       # ログイン/ログアウトを処理
               registrations: 'api/v1/registrations' # 登録を処理
             }

  # =========================================================
  # API v1 のエンドポイント定義
  # =========================================================
  namespace :api do
    namespace :v1 do
      # 認証テスト用のエンドポイント (JWTトークンが必要)
      get '/private/test', to: 'private_test#index'

      # ユーザープロフィール・一覧 
      resources :users, only: [:index, :show] do
        collection do
          get :following # GET /api/v1/users/following のためのカスタムルート
        end
      end
      
      # フォロー/アンフォロー
      resources :relationships, only: [:create, :destroy]

      # 評価（サンタ通知）
      resources :evaluations, only: [:index, :show, :create] 

      # Heartory Homeの機能（感情ログ）
      resources :emotion_logs, only: [:index, :create, :show, :update, :destroy]

      # 評価テンプレート管理
      resources :templates, only: [:index, :show]
    end
  end

  # =========================================================
  # 開発環境向けメール確認UIの追加（APIとは無関係）
  # =========================================================
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
