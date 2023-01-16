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

    it "creates an invitation for an existing user" do
      @alice = User.create!(email: "alice@email.com")
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          campaign_id: @campaign.id,
          email: @alice.email
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["campaign_id"]).to eq(@campaign.id)
    end

    it "returns an error" do
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          campaign_id: nil
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["campaign"]).to eq(["must exist"])
    end
  end

  describe "GET /api/v1/invitations/:id/redeem" do
    it "redeems an invitation and creates a new user" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: "ginny@email.com")
      patch "/api/v1/invitations/#{@invitation.id}/redeem", params: {
        user: {
          first_name: "Ginny",
          last_name: "Field",
          password: "Mother"
        }
      }
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("ginny@email.com")
      expect(Invitation.find_by(id: @invitation.id)).to be_nil

      ginny = User.find_by(email: "ginny@email.com")
      expect(ginny.player_campaigns).to include(@campaign)
    end

    it "redeems an invitation for an existing user" do
      @ginny = User.create!(email: "ginny@email.com")
      @headers = Devise::JWT::TestHelpers.auth_headers({}, @ginny)
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: @ginny.email)
      patch "/api/v1/invitations/#{@invitation.id}/redeem"
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("ginny@email.com")
      expect(Invitation.find_by(id: @invitation.id)).to be_nil

      ginny = User.find_by(email: "ginny@email.com")
      expect(ginny.player_campaigns).to include(@campaign)
    end
  end

  describe "DELETE /api/v1/invitations/:id" do
    it "deletes an invitation" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id)
      delete "/api/v1/invitations/#{@invitation.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Invitation.find_by(id: @invitation.id)).to be_nil
    end
  end
end
