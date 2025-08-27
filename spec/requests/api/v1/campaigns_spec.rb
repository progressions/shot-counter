require 'rails_helper'

RSpec.describe "Api::V1::Campaigns", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", gamemaster: true, confirmed_at: Time.now)
    @current_campaign = @gamemaster.campaigns.create!(name: "Current Campaign")
    @other_gamemaster = User.create!(email: "other@example.com", first_name: "Other", last_name: "Master", gamemaster: true)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)

    post "/api/v1/campaigns/current", params: { id: @current_campaign.id }, headers: @headers
  end

  describe "GET /campaigns" do
    it "returns campaigns" do
      @action_movie = @gamemaster.campaigns.create!(name: "Action Movie")
      @adventure = @gamemaster.campaigns.create!(name: "Adventure")

      get "/api/v1/campaigns", headers: @headers
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(campaigns["gamemaster"].map { |c| c["name"] }).to eq(["Current Campaign", "Action Movie", "Adventure"])
      expect(campaigns["player"]).to be_empty
    end

    it "returns all my campaigns, both ones I run and ones I play in" do
      @third_gamemaster = User.create!(email: "third@example.com", first_name: "Third", last_name: "Master", gamemaster: true, confirmed_at: Time.now)
      @modern = @third_gamemaster.campaigns.create!(name: "Modern")

      @action_movie = @gamemaster.campaigns.create!(name: "Action Movie")
      @adventure = @gamemaster.campaigns.create!(name: "Adventure")

      @scifi = @other_gamemaster.campaigns.create!(name: "Scifi")
      @fantasy = @other_gamemaster.campaigns.create!(name: "Fantasy")

      @scifi.users << @gamemaster
      @fantasy.users << @gamemaster

      get "/api/v1/campaigns", headers: @headers
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(campaigns["gamemaster"].map { |c| c["name"] }).to eq(["Current Campaign", "Action Movie", "Adventure"])
      expect(campaigns["player"].map { |c| c["name"] }).to eq(["Scifi", "Fantasy"])
    end
  end

  describe "POST /campaigns" do
    it "creates campaign" do
      post "/api/v1/campaigns", headers: @headers, params: {
        campaign: {
          name: "Hard to Kill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Hard to Kill")
    end

    it "returns error if you're unauthorized" do
      @player = User.create!(email: "player@email.com", first_name: "Player", last_name: "User", gamemaster: false, confirmed_at: Time.now)
      @headers = Devise::JWT::TestHelpers.auth_headers({}, @player)

      post "/api/v1/campaigns", headers: @headers, params: {
        campaign: {
          name: "Hard to Make"
        }
      }
      expect(response).to have_http_status(:forbidden)
      expect(Campaign.count).to eq(1)
    end

    it "returns errors" do
      post "/api/v1/campaigns", headers: @headers, params: {
        campaign: {
          name: ""
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body).to eq({"name" => ["can't be blank"]})
    end
  end

  describe "GET /campaigns/:id" do
    it "fetches campaign you created" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")

      @alice = User.create!(email: "alice@example.com", first_name: "Alice", last_name: "User", confirmed_at: Time.now)
      @marcie = User.create!(email: "marcie@example.com", first_name: "Marcie", last_name: "User", confirmed_at: Time.now)

      @campaign.users << @alice
      @campaign.users << @marcie

      get "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Action Movie")
      expect(body["users"].map { |u| u["email"] }).to match_array(["alice@example.com", "marcie@example.com"])
    end

    it "fetches campaign you play in" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")

      @alice = User.create!(email: "alice@example.com", first_name: "Alice", last_name: "User", confirmed_at: Time.now)
      @campaign.users << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      get "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Action Movie")
    end

    it "fetches the current campaign" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      get "/api/v1/campaigns/#{@campaign.id}", headers: @headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Action Movie")
    end

    it "returns 200" do
      get "/api/v1/campaigns/12345", headers: @headers
      expect(response).to have_http_status(200)
      expect(response.body).to eq(" ")
    end
  end

  describe "PATCH /campaigns:id" do
    it "updates campaign" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")
      patch "/api/v1/campaigns/#{@campaign.id}", headers: @headers, params: {
        campaign: {
          name: "Hard to Kill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Hard to Kill")
    end

    it "can't update a campaign you're just a player in" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")
      @alice = User.create!(email: "alice@example.com", first_name: "Alice", last_name: "User", confirmed_at: Time.now)
      @campaign.users << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      patch "/api/v1/campaigns/#{@campaign.id}", headers: @headers, params: {
        campaign: {
          name: "Hard to Change"
        }
      }
      expect(response).to have_http_status(:forbidden)
      expect(@campaign.reload.name).to eq("Action Movie")
    end
  end

  describe "DELETE /campaigns/:id" do
    it "destroys campaign" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")
      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Campaign.find_by(id: @campaign.id)).to be_nil
    end

    it "can't destroy a campaign you're just a player in" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")
      @alice = User.create!(email: "alice@example.com", first_name: "Alice", last_name: "User", confirmed_at: Time.now)
      @campaign.users << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:forbidden)
      expect(@campaign.reload).to be_present
    end

    it "even for a gamemaster, can't destroy a campaign you're a player in" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")
      @other_campaign = @gamemaster.campaigns.create!(name: "Action Moviez")
      @gm_alice = User.create!(email: "alice@example.com", first_name: "Alice", last_name: "Master", gamemaster: true, confirmed_at: Time.now)
      @other_campaign.users << @gm_alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @gm_alice)

      delete "/api/v1/campaigns/#{@other_campaign.id}", headers: @headers
      expect(response).to have_http_status(:not_found)
      expect(@other_campaign.reload).to be_present
    end

    it "can't destroy the current campaign" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")
      # set it to the current campaign
      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers

      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(401)
      expect(Campaign.find_by(id: @campaign.id)).to be_present
    end
  end

  describe "POST /set" do
    it "returns http success" do
      @campaign = @gamemaster.campaigns.create!(name: "Action Movie")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:success)

      expect(CurrentCampaign.get(user: @gamemaster.reload)).to eq(@campaign)
    end

    it "can clear current campaign" do
      post "/api/v1/campaigns/current", params: { id: nil }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(CurrentCampaign.get(user: @gamemaster)).to be_nil
    end

    it "can set campaign you're a player in" do
      @campaign = @gamemaster.campaigns.create!(name: "Adventure")
      @alice = User.create!(email: "alice@example.com", first_name: "Alice", last_name: "User", confirmed_at: Time.now)
      @campaign.users << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@alice.id}"))
      expect(user_info["campaign_id"]).to eq(@campaign.id)
    end
  end

end
