RailsBlog::Application.routes.draw do

  get 'sessions/new'

  get 'sessions/create'

  resources :users
  resources :tags
  resources :sessions
  
  resources :posts do 
    resources :comments
  end

  root 'posts#index'
  get '/signup', to: 'users#new', as: 'signup'
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'
end
