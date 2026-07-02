Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Authentication Routes
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]

  post "session/impersonate", to: "sessions#impersonate", as: :impersonate_session

  # Core Dashboard
  root "dashboard#index"

  # Topics, Comments, Upvotes
  resources :topics, only: [ :show, :create ] do
    resources :comments, only: [ :create ]
    resource :upvote, only: [ :create ]
  end

  # Service Listings
  resources :service_listings, only: [ :create ] do
    member do
      post :vouch
    end
  end

  # Reveal health status
  get "up" => "rails/health#show", as: :rails_health_check

  # Error handling
  match "/errors/404", to: "errors#not_found", via: :all
  match "/errors/500", to: "errors#internal_server_error", via: :all
  match "/errors/422", to: "errors#unprocessable_entity", via: :all
  match "*path", to: "errors#not_found", via: :all
end
