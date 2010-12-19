Ruby4Kids::Application.routes.draw do

  devise_for :users, skip: [:sessions] do
    get    '/sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    post   '/sign_in', :to => 'devise/sessions#create', :as => :user_session
    delete '/sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :users

  root to: 'dashboard#index'

end
