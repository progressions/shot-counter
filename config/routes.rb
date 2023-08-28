Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: "users/confirmations",
    passwords: "users/passwords",
  }
  namespace :api do
    namespace :v1 do
      resources :mooks
      resources :locations
      resources :characters_and_vehicles, only: [:index] do
        member do
          get :characters
          get :vehicles
        end
      end
      resources :schticks
      resources :weapons
      resources :parties do
        resources :memberships, except: [:destroy]
        delete "memberships/:id/character", to: "memberships#remove_character"
        delete "memberships/:id/vehicle", to: "memberships#remove_vehicle"
        post "fight/:fight_id", to: "parties#fight"
      end
      resources :sites
      post "schticks/import", to: "schticks#import"
      post "weapons/import", to: "weapons#import"
      resources :factions
      resources :invitations do
        member do
          patch :redeem
          post :resend
        end
      end
      resources :campaign_memberships, only: [:create]
      delete "campaign_memberships", to: "campaign_memberships#destroy"
      post "campaigns/current", to: "campaigns#set"
      resources :campaigns
      get "campaigns/current", to: "campaigns#current"
      delete "characters/:id/image", to: "characters#remove_image"
      resources :characters do
        resources :schticks, controller: "character_schticks"
        resources :advancements
        resources :sites, controller: "attunements"
        resources :weapons, controller: "carries"
      end
      resources :vehicles
      resources :users, only: [:index, :show, :update, :destroy]
      resources :fights do
        resources :character_effects, only: [:create, :update, :destroy]
        resources :effects
        resources :drivers do
          member do
            patch :act
            post :add
            patch :hide
            patch :reveal
          end
        end
        resources :actors do
          member do
            patch :act
            patch :hide
            patch :reveal
            post :add
          end
        end
      end
    end
  end
end
