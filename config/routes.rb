Ruby4Kids::Application.routes.draw do

  devise_for :users, skip: [:sessions] do
    get    '/sign_in' => 'devise/sessions#new', as: :new_user_session
    post   '/sign_in' => 'devise/sessions#create', as: :user_session
    delete '/sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :users

  match '/dashboard' => 'dashboard#index', as: :user_root

  root to: 'home#index'

end
