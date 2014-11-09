RailsBlog::Application.routes.draw do
  resources :users
  resources :tags
  
  resources :posts do 
    resources :comments
  end

  root to: "posts#index"

  get "/signup" => "users#new"
  get "/login" => "sessions#new"
  post "/login" => "sessions#create", as: :sessions
  delete "/logout" => "sessions#destroy"
end
