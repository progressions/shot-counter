Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: "users/confirmations",
    passwords: "users/passwords",
  }
  namespace :api do
    namespace :v1 do
      resources :characters_and_vehicles, only: [:index]
      resources :schticks
      resources :weapons
      post "schticks/import", to: "schticks#import"
      post "weapons/import", to: "weapons#import"
      resources :factions, only: [:index]
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
      resources :characters do
        resources :schticks, controller: "character_schticks"
        resources :advancements
        resources :sites
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
          end
        end
        resources :actors do
          member do
            patch :act
            post :add
          end
        end
      end
    end
  end
end
