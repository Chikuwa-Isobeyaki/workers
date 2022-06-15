Rails.application.routes.draw do

  devise_for :users, skip: [:passwords]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  #ホーム関連
  root :to =>"homes#top"
  get "home/about"=>"homes#about"

  # ユーザー関係
  resources :users, only: [:show,:edit,:update] do

    # フォロー関係
    resource :relationships, only: [:create,:destroy]
    get 'follows' => 'relationships#index', as: 'follows'
  end

  #ユーザー検索関係
  get 'search' => 'users#search', as: 'search'

  # 現場関連
  resources :sites do

    # 現場関係関連
    resources :site_users, only: [:index,:create],as: 'users'
    get 'add' => 'site_users#add', as: 'add_users'
    delete 'destroy/:user_id' => 'site_users#site_user_destroy',as: 'user_destroy'

    # 作業関連
    resources :works
  end

  resources :notifications, only: [:index]

end
