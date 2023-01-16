require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
  end

  describe "GET /api/v1/invitations" do
    it "returns all invitations sent by the current user" do
      @invitations = 4.times.map { @campaign.invitations.create!(user: @gamemaster) }
      get "/api/v1/invitations", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.map { |i| i["id"] }).to eq(@invitations.map(&:id))
    end
  end

  describe "POST /api/v1/invitations" do
    it "creates an invitation for the given campaign" do
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          campaign_id: @campaign.id
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["campaign_id"]).to eq(@campaign.id)
    end
  end
end
