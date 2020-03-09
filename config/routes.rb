Rails.application.routes.draw do
  root to: 'posts#index'

  resource :author, only: %i(show update edit)

  resources :channels

  resources :posts do
    member do
      get :preview
      post :like
      post :unlike
    end
  end

  get '/login' => "logins#new", as: :login
  post '/login' => "logins#new"
  get '/login/:token' => "logins#create", as: :magic_link
  get '/logout' => "logins#destroy", as: :logout

  # Bot redirects
  get 'wp-login.php' => redirect('/')
  get 'authors/wp-login.php' => redirect('/')

end
