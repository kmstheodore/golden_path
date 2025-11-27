Rails.application.routes.draw do
  devise_for :users

  # 1. If the user is logged in, send them to the dashboard.
  # We give this a distinct name (as: :authenticated_root) to prevent the naming conflict.
  authenticated :user do
    root "pages#home", as: :authenticated_root
    resources :friendships, only: [:create, :destroy]
  end

  # 2. For everyone else (guests), send them to the welcome page.
  # This defines the standard 'root_path' helper that your views are looking for.
  root "pages#welcome"
  get "paths/index"
  get "paths/new"
  get "paths/create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :web_push_subscriptions, only: [:create, :new] do
    member do
      post :test
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
   get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
   get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  resources :paths, only: [:index, :new, :create, :destroy]

  # Defines the root path route ("/")
  # root "posts#index"
end
