# get "admin/logout" => "admin/sessions#destroy"
# get "admin/login" => "admin/sessions#new", :as => :admin_login
# get 'admin/index' => 'admin/home#index', :as => :admin_root
# post 'admin/sessions' => 'admin/sessions#create', via: :post
match '/admin/home', to: 'admin/home#index', via: "get"
namespace :admin do
  root :to => 'application#index'
  namespace :manage do
    root :to => 'application#index'
    resources :sessions, :only => [:new, :create, :destroy] do
      collection do
        get 'new', as: :login
        get 'destroy', as: :logout
      end
    end
    resources :editors, :roles, :grants, :users
    resources :user do
      member do
        get :delete
      end
    end
    resources :editors do
      collection do
        post :activate_mail
      end
      member do
        get :delete
      end
    end
    resources :grants do
      member do
        get :delete
      end
    end
    resources :logs
    resources :users
    resources :sessions
  end
  namespace :fx do
    resources :levels do
      member do
        get :delete
      end
    end
    resources :users do
      member do
        get :delete, :delete_relation,:edit_relation,:children,:new_relation
        delete :remove_relation
        post :update_relation,:add_relation
      end
      collection do
        get :apply
      end
    end
    resources :trades do
      member do
        get :delete,:refund
        post :refundment
      end
    end
    resources :invites do
      member do
        get :delete
      end
    end
    resources :settings do
      collection do
        get :ui
      end
    end
    resources :upgrades
    resources :tax_rates
    resources :employees
  end
  resources :assets, :only => [:show] do
    collection do
      get :updone, :attachment,:uploads,:file_keys
      # post :updone,:upload_voice,:uptoken,:upload, :updone_save
    end
  end

end

#======admin end=============================