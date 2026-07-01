Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Authentication Routes
  resource :session, only: [:new, :create, :destroy]
  resources :passwords, param: :token, only: [:new, :create, :edit, :update]
  
  post "session/impersonate", to: "sessions#impersonate", as: :impersonate_session

  # Core Dashboard
  root "dashboard#index"

  # Topics, Comments, Upvotes
  resources :topics, only: [:show, :create] do
    resources :comments, only: [:create]
    resource :upvote, only: [:create]
  end

  # Service Listings
  resources :service_listings, only: [:create] do
    member do
      post :vouch
    end
  end

  # Reveal health status
  get "up" => "rails/health#show", as: :rails_health_check
end
