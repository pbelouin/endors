Rails.application.routes.draw do
  resources :skills do 
    get :autocomplete_skill_name, on: :collection
  end
  resources :categories
  resources :languages
  root 'pages#index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users do 
    member do
      get :request_connection
      post :add_skill
      resource :skills
      delete :remove_skill
    end
  end
  resources :user_skills do
    put :add_credit
  end
end
