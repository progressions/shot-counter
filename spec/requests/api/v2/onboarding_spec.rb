require "rails_helper"

RSpec.describe "Api::V2::Onboarding", type: :request do
  before(:each) do
    # Create users
    @gamemaster = User.create!(
      email: "gamemaster@example.com", 
      confirmed_at: Time.now, 
      gamemaster: true, 
      first_name: "Game", 
      last_name: "Master", 
      name: "Game Master"
    )
    @player = User.create!(
      email: "player@example.com", 
      confirmed_at: Time.now, 
      gamemaster: false, 
      first_name: "Player", 
      last_name: "One", 
      name: "Player One"
    )
    
    # Create campaign and set current campaign context
    @campaign = @gamemaster.campaigns.create!(name: "Test Campaign")
    
    # Setup authentication headers
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    
    set_current_campaign(@gamemaster, @campaign)
    set_current_campaign(@player, @campaign)
    
    Rails.cache.clear
  end

  describe "PATCH /api/v2/onboarding" do
    context "when user is authenticated" do
      it "updates onboarding progress with congratulations dismissed" do
        @gamemaster.ensure_onboarding_progress!
        onboarding_progress = @gamemaster.onboarding_progress
        
        patch "/api/v2/onboarding", 
          params: { 
            onboarding_progress: { 
              id: onboarding_progress.id,
              congratulations_dismissed_at: "2024-01-15T10:30:00Z" 
            } 
          }, 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["onboarding_progress"]).to be_present
        expect(json_response["onboarding_progress"]["congratulations_dismissed_at"]).to be_present
        
        # Verify database was updated
        onboarding_progress.reload
        expect(onboarding_progress.congratulations_dismissed_at).to be_present
      end

      it "updates onboarding progress with milestone timestamps" do
        @gamemaster.ensure_onboarding_progress!
        onboarding_progress = @gamemaster.onboarding_progress
        
        patch "/api/v2/onboarding", 
          params: { 
            onboarding_progress: { 
              id: onboarding_progress.id,
              first_character_created_at: "2024-01-15T10:30:00Z" 
            } 
          }, 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["onboarding_progress"]["first_character_created_at"]).to be_present
        
        # Verify database was updated
        onboarding_progress.reload
        expect(onboarding_progress.first_character_created_at).to be_present
      end

      it "updates multiple onboarding progress fields at once" do
        @gamemaster.ensure_onboarding_progress!
        onboarding_progress = @gamemaster.onboarding_progress
        
        patch "/api/v2/onboarding", 
          params: { 
            onboarding_progress: { 
              id: onboarding_progress.id,
              first_campaign_created_at: "2024-01-15T10:00:00Z",
              first_campaign_activated_at: "2024-01-15T10:15:00Z",
              first_character_created_at: "2024-01-15T10:30:00Z"
            } 
          }, 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        
        # Verify all fields were updated
        onboarding_progress.reload
        expect(onboarding_progress.first_campaign_created_at).to be_present
        expect(onboarding_progress.first_campaign_activated_at).to be_present
        expect(onboarding_progress.first_character_created_at).to be_present
      end

      it "handles invalid onboarding progress parameters gracefully" do
        @gamemaster.ensure_onboarding_progress!
        onboarding_progress = @gamemaster.onboarding_progress
        
        patch "/api/v2/onboarding", 
          params: { 
            onboarding_progress: { 
              id: onboarding_progress.id,
              invalid_field: "invalid_value"
            } 
          }, 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
      end

      it "creates onboarding progress if it doesn't exist" do
        # Delete any existing onboarding progress
        @player.onboarding_progress&.destroy
        @player.reload
        
        expect(@player.onboarding_progress).to be_nil
        
        patch "/api/v2/onboarding", 
          params: { 
            onboarding_progress: { 
              first_campaign_created_at: "2024-01-15T10:30:00Z" 
            } 
          }, 
          headers: @player_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        
        # Verify onboarding progress was created and updated
        @player.reload
        expect(@player.onboarding_progress).to be_present
        expect(@player.onboarding_progress.first_campaign_created_at).to be_present
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        patch "/api/v2/onboarding", 
          params: { 
            onboarding_progress: { 
              congratulations_dismissed_at: "2024-01-15T10:30:00Z" 
            } 
          }
        
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "PATCH /api/v2/onboarding/dismiss_congratulations" do
    context "when user is authenticated" do
      it "dismisses congratulations successfully" do
        @gamemaster.ensure_onboarding_progress!
        onboarding_progress = @gamemaster.onboarding_progress
        
        patch "/api/v2/onboarding/dismiss_congratulations", 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["onboarding_progress"]).to be_present
        expect(json_response["onboarding_progress"]["congratulations_dismissed_at"]).to be_present
        
        # Verify database was updated
        onboarding_progress.reload
        expect(onboarding_progress.congratulations_dismissed_at).to be_present
      end

      it "creates onboarding progress if it doesn't exist before dismissing" do
        # Delete any existing onboarding progress
        @player.onboarding_progress&.destroy
        @player.reload
        
        expect(@player.onboarding_progress).to be_nil
        
        patch "/api/v2/onboarding/dismiss_congratulations", 
          headers: @player_headers
        
        expect(response).to have_http_status(200)
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        
        # Verify onboarding progress was created and congratulations dismissed
        @player.reload
        expect(@player.onboarding_progress).to be_present
        expect(@player.onboarding_progress.congratulations_dismissed_at).to be_present
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        patch "/api/v2/onboarding/dismiss_congratulations"
        
        expect(response).to have_http_status(401)
      end
    end
  end
end