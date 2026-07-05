Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  scope "(:locale)", locale: /en|pt\-BR|es|ko/ do
    # Landing Page (public)
    root "landing#index"

    # Authentication Routes
    resource :session, only: [ :new, :create, :destroy ]
    resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]

    post "session/impersonate", to: "sessions#impersonate", as: :impersonate_session

    # Dashboard
    get "dashboard", to: "dashboard#index"

    # Topics, Comments, Upvotes
    resources :topics, only: [ :show, :create ] do
      resources :comments, only: [ :create ]
      resource :upvote, only: [ :create ]
    end

    # Condominium Settings (admin only)
    resource :condominium, only: [ :edit, :update ]

    # Service Listings
    resources :service_listings, only: [ :create ] do
      member do
        post :vouch
      end
    end
  end

  # Reveal health status (no locale needed)
  get "up" => "rails/health#show", as: :rails_health_check

  # Error handling (no locale needed)
  match "/errors/404", to: "errors#not_found", via: :all
  match "/errors/500", to: "errors#internal_server_error", via: :all
  match "/errors/422", to: "errors#unprocessable_entity", via: :all
  match "*path", to: "errors#not_found", via: :all
end
