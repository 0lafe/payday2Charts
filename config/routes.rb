require "sidekiq/web"
require Rails.root.join("lib/basic_rack_auth")

Rails.application.routes.draw do
  constraints BasicRackAuth.new do
    mount Sidekiq::Web => "/sidekiq"
  end

  get "up" => "rails/health#show"

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
  resources :crits, only: ['index']
  resources :gifs, only: ['index', 'show']
  resources :oauth, only: ['index']

  namespace :api do
    resources :veggie_bot do
      member do
        get 'build'
      end
    end
  end

  resources :jeopardy_games do
    member do
      get "reset"
      post "next_game"
      patch "answer_final_question"
      patch "answer_question"
    end
  end

  resources :guess_whos, only: ['index', 'show', 'create']

  resources :jeopardy_questions, only: [:show, :update]

  resources :jeopardy_players, only: [:update]

  resources :sessions, only: [:new, :destroy] do
    collection do
      post "redirect_to_steam"
      get "process_openid_return"
    end
  end

  resources :charts, only: [:index]

  resources :skins, only: [:index, :show] do
    collection do
      get "top_inventories"
      get "inventory_search"
      get "item_search"
    end
  end

  root "leaderboards#index"
end
