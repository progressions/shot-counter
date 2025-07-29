Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: "users/confirmations",
    passwords: "users/passwords",
  }
  namespace :api do
    namespace :v2 do
      resources :characters do
        member do
          delete :image, to: "characters#remove_image"
          post :sync
          get :pdf
        end
      end
      resources :weapons do
        member do
          delete :image, to: "weapons#remove_image"
        end
      end
      resources :vehicles do
        member do
          delete :image, to: "vehicles#remove_image"
        end
      end
      resources :junctures do
        member do
          delete :image, to: "junctures#remove_image"
        end
      end
      resources :sites do
        member do
          delete :image, to: "sites#remove_image"
        end
      end
      resources :parties do
        member do
          delete :image, to: "parties#remove_image"
        end
      end
      resources :schticks do
        member do
          delete :image, to: "schticks#remove_image"
        end
      end
      resources :factions do
        member do
          delete :image, to: "factions#remove_image"
        end
      end
      resources :fights do
        member do
          delete :image, to: "fights#remove_image"
          patch :touch
        end
      end
    end
    namespace :v1 do
      resources :ai, only: [:create]
      resources :suggestions, only: [:index]
      get "notion/characters", to: "notion#characters"
      resources :junctures do
        member do
          delete :image, to: "sites#remove_image"
        end
      end
      resources :mooks
      resources :locations, except: [:index, :destroy]
      resources :characters_and_vehicles, only: [:index] do
        member do
          get :characters
          get :vehicles
        end
      end
      resources :schticks
      resources :weapons do
        member do
          delete :image, to: "weapons#remove_image"
        end
      end
      resources :parties do
        resources :memberships, except: [:destroy]
        delete "memberships/:id/character", to: "memberships#remove_character"
        delete "memberships/:id/vehicle", to: "memberships#remove_vehicle"
        post "fight/:fight_id", to: "parties#fight"
        member do
          delete :image, to: "parties#remove_image"
        end
      end
      resources :sites do
        member do
          delete :image, to: "sites#remove_image"
        end
      end
      post "schticks/import", to: "schticks#import"
      post "weapons/import", to: "weapons#import"
      resources :factions do
        member do
          delete :image, to: "factions#remove_image"
        end
      end
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
      post "characters/pdf", to: "characters#import"
      resources :characters do
        resources :schticks, controller: "character_schticks"
        resources :advancements
        resources :sites, controller: "attunements"
        resources :weapons, controller: "carries"
        member do
          delete :image, to: "characters#remove_image"
          post :sync
          get :pdf
        end
      end
      get "vehicles/archetypes", to: "vehicles#archetypes"
      resources :vehicles do
        member do
          delete :image, to: "vehicles#remove_image"
        end
      end
      resources :users, only: [:index, :show, :update, :destroy] do
        get :current, on: :collection
        member do
          delete :image, to: "users#remove_image"
        end
      end
      resources :fights do
        member do
          patch :touch
        end
        resources :fight_events, only: [:index, :create]
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
