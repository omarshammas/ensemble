Ensemble::Application.routes.draw do
  resources :votes
  resources :tasks
  resources :users do
    resources :tasks
  end

  get "authenticate" => "sessions#authenticate", as: :authenticate
  get "logout" => "sessions#destroy", as: :logout
  post "sessions/login", as: :login
  post "sessions/signup", as: :signup

  get "user/dashboard", as: :dashboard
  root to: 'user#dashboard', as: :home
  
  match 'turk/tasks/:id' => "turk#tasks"
  match ':controller(/:action(/:id(.:format)))'
end
