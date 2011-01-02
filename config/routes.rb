Ruby4Kids::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "users/oauth_callbacks" }, skip: [:sessions] do
    get    '/sign_in' => 'devise/sessions#new', as: :new_user_session
    post   '/sign_in' => 'devise/sessions#create', as: :user_session
    delete '/sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :users

  match '/dashboard' => 'dashboard#index', as: :user_root

  root to: 'pages#home'

  match '/:page' => 'pages#show', as: :page

end
#== Route Map
# Generated on 01 Jan 2011 21:19
#
#         new_user_session GET    /sign_in(.:format)                     {:controller=>"devise/sessions", :action=>"new"}
#             user_session POST   /sign_in(.:format)                     {:controller=>"devise/sessions", :action=>"create"}
#     destroy_user_session DELETE /sign_out(.:format)                    {:controller=>"devise/sessions", :action=>"destroy"}
#   user_omniauth_callback        /users/auth/:action/callback(.:format) {:action=>/facebook/, :controller=>"users/oauth_callbacks"}
#            user_password POST   /users/password(.:format)              {:action=>"create", :controller=>"devise/passwords"}
#        new_user_password GET    /users/password/new(.:format)          {:action=>"new", :controller=>"devise/passwords"}
#       edit_user_password GET    /users/password/edit(.:format)         {:action=>"edit", :controller=>"devise/passwords"}
#                          PUT    /users/password(.:format)              {:action=>"update", :controller=>"devise/passwords"}
# cancel_user_registration GET    /users/cancel(.:format)                {:action=>"cancel", :controller=>"devise/registrations"}
#        user_registration POST   /users(.:format)                       {:action=>"create", :controller=>"devise/registrations"}
#    new_user_registration GET    /users/sign_up(.:format)               {:action=>"new", :controller=>"devise/registrations"}
#   edit_user_registration GET    /users/edit(.:format)                  {:action=>"edit", :controller=>"devise/registrations"}
#                          PUT    /users(.:format)                       {:action=>"update", :controller=>"devise/registrations"}
#                          DELETE /users(.:format)                       {:action=>"destroy", :controller=>"devise/registrations"}
#        user_confirmation POST   /users/confirmation(.:format)          {:action=>"create", :controller=>"devise/confirmations"}
#    new_user_confirmation GET    /users/confirmation/new(.:format)      {:action=>"new", :controller=>"devise/confirmations"}
#                          GET    /users/confirmation(.:format)          {:action=>"show", :controller=>"devise/confirmations"}
#              user_unlock POST   /users/unlock(.:format)                {:action=>"create", :controller=>"devise/unlocks"}
#          new_user_unlock GET    /users/unlock/new(.:format)            {:action=>"new", :controller=>"devise/unlocks"}
#                          GET    /users/unlock(.:format)                {:action=>"show", :controller=>"devise/unlocks"}
#                    users GET    /users(.:format)                       {:action=>"index", :controller=>"users"}
#                          POST   /users(.:format)                       {:action=>"create", :controller=>"users"}
#                 new_user GET    /users/new(.:format)                   {:action=>"new", :controller=>"users"}
#                edit_user GET    /users/:id/edit(.:format)              {:action=>"edit", :controller=>"users"}
#                     user GET    /users/:id(.:format)                   {:action=>"show", :controller=>"users"}
#                          PUT    /users/:id(.:format)                   {:action=>"update", :controller=>"users"}
#                          DELETE /users/:id(.:format)                   {:action=>"destroy", :controller=>"users"}
#                user_root        /dashboard(.:format)                   {:controller=>"dashboard", :action=>"index"}
#                     root        /(.:format)                            {:controller=>"pages", :action=>"home"}
#                     page        /:page(.:format)                       {:controller=>"pages", :action=>"show"}
#                   jammit        /assets/:package.:extension(.:format)  {:extension=>/.+/, :controller=>"jammit", :action=>"package"}
