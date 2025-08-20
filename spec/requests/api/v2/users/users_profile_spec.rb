require "rails_helper"

RSpec.describe "Api::V2::Users Profile", type: :request do
  before(:each) do
    @user = User.create!(email: "test@example.com", confirmed_at: Time.now, first_name: "Test", last_name: "User", name: "Test User")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @user)
  end

  describe "GET /api/v2/users/profile" do
    it "returns current user's profile" do
      get "/api/v2/users/profile", headers: @headers
      expect(response).to have_http_status(:success)
      
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(@user.id)
      expect(body["first_name"]).to eq("Test")
      expect(body["last_name"]).to eq("User")
      expect(body["email"]).to eq("test@example.com")
      expect(body["entity_class"]).to eq("User")
    end

    it "returns campaign counts" do
      # Create campaigns as gamemaster
      campaign1 = @user.campaigns.create!(name: "Test Campaign 1", description: "Test", active: true)
      campaign2 = @user.campaigns.create!(name: "Test Campaign 2", description: "Test", active: true)
      
      # Create campaign as player
      other_user = User.create!(email: "gm@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "GM", last_name: "User")
      player_campaign = other_user.campaigns.create!(name: "Player Campaign", description: "Test", active: true)
      player_campaign.campaign_memberships.create!(user: @user)

      get "/api/v2/users/profile", headers: @headers
      expect(response).to have_http_status(:success)
      
      body = JSON.parse(response.body)
      expect(body["campaigns_as_gm_count"]).to eq(2)
      expect(body["campaigns_as_player_count"]).to eq(1)
    end

    it "requires authentication" do
      get "/api/v2/users/profile"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v2/users/profile" do
    it "updates current user's profile" do
      user_data = {
        first_name: "Updated",
        last_name: "Name"
      }
      
      patch "/api/v2/users/profile", 
            params: { user: user_data }, 
            headers: @headers

      expect(response).to have_http_status(:success)
      
      body = JSON.parse(response.body)
      expect(body["first_name"]).to eq("Updated")
      expect(body["last_name"]).to eq("Name")
      
      @user.reload
      expect(@user.first_name).to eq("Updated")
      expect(@user.last_name).to eq("Name")
    end

    it "updates user email separately" do
      user_data = {
        email: "newemail@example.com"
      }
      
      patch "/api/v2/users/profile", 
            params: { user: user_data }, 
            headers: @headers

      expect(response).to have_http_status(:success)
      
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("newemail@example.com")
      
      @user.reload
      expect(@user.email).to eq("newemail@example.com")
    end

    it "returns validation errors for invalid data" do
      patch "/api/v2/users/profile", 
            params: { user: { email: "invalid-email" } }, 
            headers: @headers

      expect(response).to have_http_status(:unprocessable_entity)
      
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end

    it "requires authentication" do
      patch "/api/v2/users/profile", params: { user: { first_name: "Test" } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns new JWT token in header" do
      patch "/api/v2/users/profile", 
            params: { user: { first_name: "Updated" } }, 
            headers: @headers

      expect(response).to have_http_status(:success)
      expect(response.headers["Authorization"]).to be_present
      expect(response.headers["Authorization"]).to start_with("Bearer ")
    end
  end
end