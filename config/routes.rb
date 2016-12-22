class ActionDispatch::Routing::Mapper
  def draw(routes_name, namespace_name=nil)
    instance_eval(File.read(Rails.root.join("config/routes", namespace_name.to_s, "#{routes_name}.rb")))
  end
end

Rails.application.routes.draw do
  draw :admin
  draw :api
  root 'fx/home#index'
  #get 'auth' => 'fx/home#index'
  match 'auth', to: 'fx/home#index', via: [:get, :post]
  get "login" => "core/sessions#new", :as => :login
  get "invite/:id" => "users#invite"
  get 'logout' => "core/sessions#logout", :as => :logout
  get '/docs/index', to: 'docs#index'
  get "fx/signup" => "fx/users#new", :as => :signup
  get 'qrcode/:id' => 'fx/home#qrcode'
  namespace :core do
    resources :sessions, :only => [:new, :create] do
      collection do
        get :forget_password, :get_sms, :success, :show_reset_password, :logout
        post :reset_password, :validate_account, :validate_code, :captcha_login
      end
    end
  end
  namespace :fx do
    resources :users do
      collection do
        get :register,:apply
        post :validate_code,:validate_params,:send_sms
      end
    end
  
    resources :home, :only=>[:index] do
      collection do 
        get :activate,:return_amount ,:tax_rates,:apply,:reback,:note,:verify
      end
    end
    
    resources :withdraws, :only=>[:index,:new,:create] do
       
    end
    
    
    get "download"=>"home#download"
 
  end
end
