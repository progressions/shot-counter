Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  namespace :api do
    namespace :v1 do
      resources :all_characters
      resources :users, only: [:index, :show, :update, :destroy]
      resources :fights do
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
