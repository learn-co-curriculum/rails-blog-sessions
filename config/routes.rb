RailsBlog::Application.routes.draw do
  resources :users
  resources :tags
  
  resources :posts do 
    resources :comments
  end
  
  root 'posts#index'
  get 'signup' => 'users#new', :as => 'signup'
  
end
