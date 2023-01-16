require "rails_helper"

RSpec.describe "Api::V1::CampaignMemberships", type: :request do
  before(:each) do
    @user = User.create!(email: "email@example.com")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @user)
    @action_movie = @user.campaigns.create!(title: "Action Movie")
    @adventure = @user.campaigns.create!(title: "Adventure")
    @weird = @user.campaigns.create!(title: "Weird World")
  end

  describe "GET /campaign_memberships" do
    it "returns all the campaigns I'm a player in" do
      @action_movie.players << @user
      @adventure.players << @user

      get "/api/v1/campaign_memberships", headers: @headers
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(campaigns.map { |c| c["title"] }).to eq(["Action Movie", "Adventure"])
    end
  end

  describe "POST /campaign_memberships" do
    it "adds the user to a campaign as a player" do
      post "/api/v1/campaign_memberships", headers: @headers, params: {
        membership: { campaign_id: @action_movie.id }
      }
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(@user.player_campaigns.map { |c| c["title"] }).to eq(["Action Movie"])
    end
  end

  describe "DELETE /campaign_memberships/:id" do
    it "removes the player's membership" do
      @action_movie.players << @user

      delete "/api/v1/campaign_memberships/#{@action_movie.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@user.player_campaigns).to eq([])
    end
  end
end
