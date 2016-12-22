get "t/:token" => "api/v1/task/tasks#visit"
get "tasks/:id/content" => "api/v1/task/tasks#content"
get "api/v1/hfbpay/recharges/checkout" => "hfbpay/recharges#checkout"

namespace :api do
  namespace :v1 do
    post "users/login" => "sessions#create", :as => :login
    post "users/logout" => "sessions#logout", :as => :logout
    post "uptoken" => "home#uptoken", :as => :uptoken
    namespace :fx do
      get "posters" => "home#posters"
      get "info" => "home#info"
      resources :trades
      resources :users do
        member do
          get :qrcode,:note
        end
        collection do
          post :apply,:invalid
          get :check 
        end
        resources :transations
      end
      resources :withdraws do
        collection do
          get :bang_amount
          get :tax_rate_check
        end
      end
      resources :tax_rates
    end
  end
end