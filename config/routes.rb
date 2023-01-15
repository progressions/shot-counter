Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  namespace :api do
    namespace :v1 do
      post "campaigns/current", to: "campaigns#set"
      resources :campaigns
      get "campaigns/current", to: "campaigns#current"
      resources :all_characters
      resources :all_vehicles
      resources :users, only: [:index, :show, :update, :destroy]
      resources :fights do
        resources :effects
        resources :vehicles do
          member do
            patch :act
            post :add
          end
        end
        resources :characters do
          member do
            patch :act
            post :add
          end
        end
      end
    end
  end
end
