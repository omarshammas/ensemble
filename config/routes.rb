Ensemble::Application.routes.draw do
  resources :preferences
  resources :votes
  resources :users do
    resources :tasks do
      resources :suggestions
    end
  end

  get "authenticate" => "sessions#authenticate", as: :authenticate
  get "logout" => "sessions#destroy", as: :logout
  post "sessions/login", as: :login
  post "sessions/signup", as: :signup

  root to: 'user#dashboard', as: :home
  
  match '/preview', :to => 'preview#load'
  match 'turk/tasks/:id' => "turk#tasks"
  match ':controller(/:action(/:id(.:format)))'
end
