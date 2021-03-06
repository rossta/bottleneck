require 'resque/server'

Bottleneck::Application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1 do
      resources :projects do
        resource :summary, only: [:show]
        resource :output, only: [:show]
      end
      resources :cumulative_flows

      match "/login", to: "sessions#create", via: :post
      match "/logout", to: "sessions#destroy", via: :delete

      match "/users/me", to: "users#me"
      resources :users
    end
  end

  authenticated :user do
    root to: 'dashboard#show', as: :dashboard
  end
  root to: "home#index"
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :users
  resources :trello_accounts do
    collection do
      get :authorize
      get :callback
    end
  end

  match '/projects/start', to: 'trello_accounts#new', as: :start_project

  resources :projects do
    member do
      put :refresh
    end

    collection do
      get :clear
    end

    resources :lists
    resources :cards
    resource :cumulative_flow, path: :flow, as: :flow, only: [:show, :edit]
    resource :output, path: :output, as: :output, only: [:show]
    resource :breakdown, path: :breakdown, as: :breakdown, only: [:show]
  end

  admin_constraint = lambda do |request|
    request.env['warden'] &&
    request.env['warden'].user &&
    request.env['warden'].user.has_role?(:admin)
  end
  # scope "/admin", constraints: admin_constraint do
    # mount Resque::Server.new, at: "/resque"
  # end
end
