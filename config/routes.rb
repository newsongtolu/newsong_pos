Rails.application.routes.draw do
  # 1. Staff Authentication with Custom Sessions Controller & OTP Routes
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'verify_otp', to: 'users/sessions#verify_otp', as: :verify_otp
    post 'confirm_otp', to: 'users/sessions#confirm_otp', as: :confirm_otp
  end

  # 2. Public Customer-Facing Gateway and Menu
  root "orders#index"
  get "menu", to: "store#index", as: :menu
  resources :orders, only: [:index, :create, :show] do
    collection do
      get :confirmation
      post :set_service_mode
    end
  end

  # 3. Automated Payment Gateway Webhook
  post "webhooks/paystack", to: "webhooks#paystack"

  # 4. Cashier Terminal
  namespace :cashier do
    root to: "orders#index"
    resources :orders, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        patch :verify_payment
        get :add_items
        post :append_item
      end
    end
  end

  # 5. Super Admin Workspace
  namespace :super_admin do
    get 'dashboards', to: 'dashboards#index'
    resources :users
    resources :settings, only: [:index, :update]
  end

  # 6. Admin Workspace
  namespace :admin do
    resources :dashboards, only: [:index]
    resources :menu_items, only: [:index, :create, :update, :destroy] do
      patch :toggle_stock, on: :member
    end
    resources :orders, only: [:index, :update]
    resources :reports, only: [:index]
    resources :users
  end

  # 7. Fulfillment Stations (Kitchen, Floor, Dispatch)
  namespace :kitchen do
    root to: "orders#index"
    resources :orders, only: [:index, :update] do
      member do
        patch :update_status
      end
    end
  end
  
  namespace :floor do
    root to: "orders#index"
    resources :orders, only: [:index, :update] do      
      member do
        patch :update_status
      end
    end 
  end
  
  namespace :dispatch do
    root to: "orders#index"
    resources :orders, only: [:index, :update] do
      member do
        patch :update_status
      end
    end
  end
end