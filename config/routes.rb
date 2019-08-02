Rails.application.routes.draw do
  devise_for :users,
            path: '',
            path_names: {sign_up: 'register', sign_in: 'login', edit: 'profile', sign_out: 'logout'},
            controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registration: 'users/registration' }
  root to: 'pages#home'
  get '/dashboard', to: 'users#dashboard'
  get 'users/:id', to: 'users#show'
  post '/users/edit', to: 'users#update'
  resources :gigs do
    member do
      delete :delete_photo
      post :upload_photo
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
