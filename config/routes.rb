Rails.application.routes.draw do
  resources :users
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  get 'user-notifications' => 'application#notifications'
  get 'search-repos' => 'application#search_repos'
  post 'find-repos' => 'application#find_repos'
  get 'user-favorite-repos' => 'application#fav_repos'

  get 'user-info' => 'application#user_info'

end
