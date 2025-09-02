require "rails_helper"

RSpec.describe "Api::V2::Encounters - Act Action", type: :request do
  before(:each) do
    # Create users
    @gamemaster = User.create!(
      email: "gamemaster@example.com", 
      first_name: "Game", 
      last_name: "Master", 
      confirmed_at: Time.now, 
      gamemaster: true,
      password: "password123"
    )
    
    # Create campaign
    @campaign = @gamemaster.campaigns.create!(name: "Test Campaign")
    
    # Create fight
    @fight = @campaign.fights.create!(name: "Test Fight")
    
    # Create character
    @character = Character.create!(
      name: "Test Character",
      action_values: { 
        "Type" => "PC", 
        "Speed" => 5
      },
      campaign_id: @campaign.id,
      user_id: @gamemaster.id
    )
    
    # Create shot
    @shot = @fight.shots.create!(
      character: @character,
      shot: 10,
      count: 0,
      impairments: 0
    )
    
    # Set up authentication
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "PATCH /api/v2/encounters/:id/act" do
    it "reduces the shot value by the default amount" do
      original_shot = @shot.shot
      
      patch "/api/v2/encounters/#{@fight.id}/act", 
        params: {
          shot_id: @shot.id
        },
        headers: @headers
      
      expect(response).to have_http_status(:success)
      
      @shot.reload
      expect(@shot.shot).to eq(original_shot - Fight::DEFAULT_SHOT_COUNT)
    end
    
    it "reduces the shot value by a custom amount" do
      original_shot = @shot.shot
      custom_cost = 2
      
      patch "/api/v2/encounters/#{@fight.id}/act", 
        params: {
          shot_id: @shot.id,
          shots: custom_cost
        },
        headers: @headers
      
      expect(response).to have_http_status(:success)
      
      @shot.reload
      expect(@shot.shot).to eq(original_shot - custom_cost)
    end
    
    it "can set an action_id on the fight" do
      action_id = SecureRandom.uuid
      
      patch "/api/v2/encounters/#{@fight.id}/act", 
        params: {
          shot_id: @shot.id,
          action_id: action_id
        },
        headers: @headers
      
      expect(response).to have_http_status(:success)
      
      @fight.reload
      expect(@fight.action_id).to eq(action_id)
    end
    
    it "returns the updated encounter data" do
      patch "/api/v2/encounters/#{@fight.id}/act", 
        params: {
          shot_id: @shot.id
        },
        headers: @headers
      
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      
      expect(body["id"]).to eq(@fight.id)
      expect(body["name"]).to eq("Test Fight")
      expect(body["shots"]).to be_an(Array)
    end
    
    it "returns an error for invalid shot_id" do
      patch "/api/v2/encounters/#{@fight.id}/act", 
        params: {
          shot_id: "invalid-uuid"
        },
        headers: @headers
      
      # This will actually return a 404 since the shot is not found
      expect(response).to have_http_status(:not_found)
    end
    
    it "requires authentication" do
      patch "/api/v2/encounters/#{@fight.id}/act", 
        params: {
          shot_id: @shot.id
        }
      
      expect(response).to have_http_status(:unauthorized)
    end
  end
end