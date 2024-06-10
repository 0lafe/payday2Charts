Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  resources :stats, only: ['show']
  resources :leaderboards, only: ['index', 'show'] do
    member do
      get 'top_100'
    end
    collection do
      get 'top_100_index'
    end
  end
  resources :users, only: ['create']
  resources :crits, only: ['index'] do
    collection do
      post :calculate
    end
  end
  resources :gifs, only: ['index', 'show']
  resources :oauth, only: ['index']

  namespace :api do
    resources :veggie_bot do
      member do
        get 'build'
      end
    end
  end

  root "homes#index"
end
