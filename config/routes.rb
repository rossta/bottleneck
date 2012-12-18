Sternoapp::Application.routes.draw do
  resources :card_intervals


  resources :list_intervals


  resources :board_intervals


  resources :cards


  resources :lists


  authenticated :user do
    root :to => 'dashboard#show'
  end
  root :to => "home#index"
  devise_for :users

  resources :users
  resources :trello_accounts do
    collection do
      get :callback    # three-legged OAuth currently not functional
    end
  end

  match '/projects/start', to: 'trello_accounts#new', as: :start_project

  resources :projects do
    member do
      put :refresh
    end

    resource :cumulative_flow, path: :flow, as: :flow, only: [:show, :edit]
  end
end
