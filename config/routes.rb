Rails.application.routes.draw do
  devise_for :users

  # If the user is logged in, the root path is the home dashboard
  authenticated :user do
    root "pages#home" # REMOVED: as: :authenticated_root
  end

  # If the user is NOT logged in, the root path is the welcome page
  unauthenticated do
    root "pages#welcome" # REMOVED: as: :unauthenticated_root
  end
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
