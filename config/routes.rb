Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  get 'dashboard',                to: 'dashboard#index'
  get '/auth/:provider/callback', to: 'connections#create'
  get 'fellowship',               to: 'home#fellowship'
  get 'contact',                  to: 'home#contact'
  get 'calendar',                 to: 'home#calendar'
  get 'api/uid',                  to: 'api#uid'
  get 'graphs/full'
  get 'graphs/friends'
  get 'graphs/access'

  post 'webhooks',                   to: 'webhooks#index'

  resources :connections, only: [:destroy] do
    collection do
      post :check_friends
    end
  end

  resource :subscription, only: [:edit, :update] do
    get :checkout
    post :process_card
  end

  devise_for :users, path: 'account', controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    get 'membership', to: 'users/registrations#new'
  end

  root to: 'home#index'
end
