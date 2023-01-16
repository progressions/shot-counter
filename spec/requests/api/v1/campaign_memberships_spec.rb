require "rails_helper"

RSpec.describe "Api::V1::CampaignMemberships", type: :request do
  # Current user must be owner of Campaign to add other users as players
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @action_movie = @gamemaster.campaigns.create!(title: "Action Movie")
    @adventure = @gamemaster.campaigns.create!(title: "Adventure")
    @weird = @gamemaster.campaigns.create!(title: "Weird World")

    @alice = User.create!(email: "alice@example.com")
    @marcie = User.create!(email: "marcie@example.com")
  end

  describe "POST /campaign_memberships" do
    it "adds the user to a campaign as a player" do
      post "/api/v1/campaign_memberships", headers: @headers, params: {
        membership: {
          user_id: @alice.id,
          campaign_id: @action_movie.id
        }
      }
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /campaign_memberships/:id" do
    it "removes the player's membership" do
      @action_movie.players << @gamemaster

      delete "/api/v1/campaign_memberships/#{@action_movie.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@gamemaster.player_campaigns).to eq([])
    end
  end
end
