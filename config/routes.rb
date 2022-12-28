Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  namespace :api do
    namespace :v1 do
      resources :fights do
        resources :characters do
          member do
            patch :act
          end
        end
      end
    end
  end
end
