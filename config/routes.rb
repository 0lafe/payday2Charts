Rails.application.routes.draw do
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

  resources :sessions, only: [:index, :new, :destroy]

  resources :charts, only: [:index]

  root "leaderboards#index"
end
