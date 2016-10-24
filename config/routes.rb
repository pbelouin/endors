Rails.application.routes.draw do
  resources :languages
  root 'pages#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  resources :users do 
    member do
      get :request_connection
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
