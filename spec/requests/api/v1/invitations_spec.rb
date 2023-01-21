require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
  end

  describe "GET /api/v1/invitations" do
    it "returns all invitations sent by the current user" do
      @invitations = 4.times.map { |i| @campaign.invitations.create!(email: "alice_#{i}@email.com", user: @gamemaster) }
      get "/api/v1/invitations", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.map { |i| i["id"] }).to eq(@invitations.map(&:id))
    end
  end

  describe "GET /api/v1/invitations/:id" do
    it "returns an existing invitation" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: "ginny@email.com")
      get "/api/v1/invitations/#{@invitation.id}"
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("ginny@email.com")
    end

    it "updates pending user" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: "ginny@email.com")
      @ginny = User.create!(email: "ginny@email.com")
      get "/api/v1/invitations/#{@invitation.id}"
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("ginny@email.com")
      expect(body["pending_user"]).to eq({"email" => @ginny.email, "id" => @ginny.id})
    end
  end

  describe "POST /api/v1/invitations" do
    it "creates an invitation for the given campaign" do
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          campaign_id: @campaign.id,
          email: "alice@email.com"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["campaign"]["id"]).to eq(@campaign.id)
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
      expect(body["campaign"]["id"]).to eq(@campaign.id)

      @invitation = @campaign.invitations.first
      expect(@invitation.pending_user).to eq(@alice)
    end

    it "creates an invitation with a maximum count" do
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          campaign_id: @campaign.id,
          maximum_count: 20
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      @invitation = Invitation.find_by(campaign_id: @campaign.id, maximum_count: 20)
      expect(@invitation).to be_present
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

    it "can't create a new invitation for the gamemaster" do
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          email: @gamemaster.email,
          campaign_id: @campaign.id
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq(["is the gamemaster"])

      expect(Invitation.count).to eq(0)
    end

    it "can't create a new invitation for an existing member" do
      @ginny = User.create!(email: "ginny@email.com")
      @campaign.players << @ginny
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          email: "ginny@email.com",
          campaign_id: @campaign.id
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq(["is already a player"])

      expect(Invitation.count).to eq(0)
    end

    it "can't create a duplicate invitation for the same email" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: "ginny@email.com")
      post "/api/v1/invitations", headers: @headers, params: {
        invitation: {
          email: "ginny@email.com",
          campaign_id: @campaign.id
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq(["has already been taken"])
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

    it "redeems for an existing user and reduces the count" do
      @alice = User.create!(email: "alice@email.com", confirmed_at: Time.now)
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, maximum_count: 10)
      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)
      patch "/api/v1/invitations/#{@invitation.id}/redeem", headers: @headers
      expect(response).to have_http_status(200)
      expect(@invitation.reload.remaining_count).to eq(9)
    end

    it "redeems, creates a new user, and reduces the count" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, maximum_count: 10)
      patch "/api/v1/invitations/#{@invitation.id}/redeem", params: {
        user: {
          email: "ginny@email.com",
          first_name: "Ginny",
          last_name: "Field",
          password: "Mother"
        }
      }
      expect(response).to have_http_status(200)
      expect(@invitation.reload.remaining_count).to eq(9)
    end

    it "can't redeem when it reaches zero remaining_count" do
      @alice = User.create!(email: "alice@email.com", confirmed_at: Time.now)
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, maximum_count: 10, remaining_count: 0)
      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)
      patch "/api/v1/invitations/#{@invitation.id}/redeem", headers: @headers
      expect(response).to have_http_status(403)
      expect(@invitation.reload.remaining_count).to eq(0)
    end

    it "redeems an invitation for an existing user" do
      @ginny = User.create!(email: "ginny@email.com")
      @headers = Devise::JWT::TestHelpers.auth_headers({}, @ginny)
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: @ginny.email)

      # User doesn't need to be signed in
      patch "/api/v1/invitations/#{@invitation.id}/redeem"

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("ginny@email.com")
      expect(Invitation.find_by(id: @invitation.id)).to be_nil

      ginny = User.find_by(email: "ginny@email.com")
      expect(ginny.player_campaigns).to include(@campaign)
    end

    it "returns an error for an invalid email address" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, maximum_count: 10)
      patch "/api/v1/invitations/#{@invitation.id}/redeem", params: {
        user: {
          email: "ginny",
          first_name: "Ginny",
          last_name: "Field",
          password: "Mother"
        }
      }
      expect(response).to have_http_status(400)
      expect(@invitation.reload.remaining_count).to eq(9)
    end
  end

  describe "POST /api/v1/invitations/:id/resend" do
    it "resends the invitation email to the user" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, email: "alice@email.com")
      expect(UserMailer).to receive_message_chain(:with, :invitation, :deliver_later!)
      post "/api/v1/invitations/#{@invitation.id}/resend", headers: @headers
      expect(response).to have_http_status(:success)
    end

    it "returns an error if the invitation has no email" do
      @invitation = @gamemaster.invitations.create!(campaign_id: @campaign.id, maximum_count: 10)
      expect(UserMailer).not_to receive(:with)
      post "/api/v1/invitations/#{@invitation.id}/resend", headers: @headers
      expect(response).to have_http_status(400)
    end
  end

  describe "DELETE /api/v1/invitations/:id" do
    it "deletes an invitation" do
      @invitation = @gamemaster.invitations.create!(email: "alice@email.com", campaign_id: @campaign.id)
      delete "/api/v1/invitations/#{@invitation.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Invitation.find_by(id: @invitation.id)).to be_nil
    end
  end
end
