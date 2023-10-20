Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  resources :stats, only: ['show']
  resources :leaderboards, only: ['index', 'show']
  resources :users, only: ['create']
  resources :crits, only: ['index'] do
    collection do
      post :calculate
    end
  end

  root "homes#index"
end
