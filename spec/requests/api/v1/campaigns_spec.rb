require 'rails_helper'

RSpec.describe "Api::V1::Campaigns", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", gamemaster: true, confirmed_at: Time.now)
    @other_gamemaster = User.create!(email: "other@example.com", gamemaster: true)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
  end

  describe "GET /campaigns" do
    it "returns campaigns" do
      @action_movie = @gamemaster.campaigns.create!(title: "Action Movie")
      @adventure = @gamemaster.campaigns.create!(title: "Adventure")

      get "/api/v1/campaigns", headers: @headers
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(campaigns["gamemaster"].map { |c| c["title"] }).to eq(["Action Movie", "Adventure"])
      expect(campaigns["player"]).to be_empty
    end

    it "returns all my campaigns, both ones I run and ones I play in" do
      @third_gamemaster = User.create!(email: "third@example.com", gamemaster: true, confirmed_at: Time.now)
      @modern = @third_gamemaster.campaigns.create!(title: "Modern")

      @action_movie = @gamemaster.campaigns.create!(title: "Action Movie")
      @adventure = @gamemaster.campaigns.create!(title: "Adventure")

      @scifi = @other_gamemaster.campaigns.create!(title: "Scifi")
      @fantasy = @other_gamemaster.campaigns.create!(title: "Fantasy")

      @scifi.players << @gamemaster
      @fantasy.players << @gamemaster

      get "/api/v1/campaigns", headers: @headers
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(campaigns["gamemaster"].map { |c| c["title"] }).to eq(["Action Movie", "Adventure"])
      expect(campaigns["player"].map { |c| c["title"] }).to eq(["Scifi", "Fantasy"])
    end
  end

  describe "POST /campaigns" do
    it "creates campaign" do
      post "/api/v1/campaigns", headers: @headers, params: {
        campaign: {
          title: "Hard to Kill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Hard to Kill")
    end

    it "returns error if you're unauthorized" do
      @player = User.create!(email: "player@email.com", gamemaster: false, confirmed_at: Time.now)
      @headers = Devise::JWT::TestHelpers.auth_headers({}, @player)

      post "/api/v1/campaigns", headers: @headers, params: {
        campaign: {
          title: "Hard to Make"
        }
      }
      expect(response).to have_http_status(:forbidden)
      expect(Campaign.count).to eq(0)
    end

    it "returns errors" do
      post "/api/v1/campaigns", headers: @headers, params: {
        campaign: {
          title: ""
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body).to eq({"title" => ["can't be blank"]})
    end
  end

  describe "GET /campaigns/:id" do
    it "fetches campaign you created" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")

      @alice = User.create!(email: "alice@example.com", confirmed_at: Time.now)
      @marcie = User.create!(email: "marcie@example.com", confirmed_at: Time.now)

      @campaign.players << @alice
      @campaign.players << @marcie

      get "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Action Movie")
      expect(body["players"].map { |u| u["email"] }).to eq(["alice@example.com", "marcie@example.com"])
    end

    it "fetches campaign you play in" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")

      @alice = User.create!(email: "alice@example.com", confirmed_at: Time.now)
      @campaign.players << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      get "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Action Movie")
    end

    it "fetches the current campaign" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      get "/api/v1/campaigns/#{@campaign.id}", headers: @headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Action Movie")
    end

    it "returns 404" do
      get "/api/v1/campaigns/12345", headers: @headers
      expect(response).to have_http_status(404)
    end
  end

  describe "PATCH /campaigns:id" do
    it "updates campaign" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")
      patch "/api/v1/campaigns/#{@campaign.id}", headers: @headers, params: {
        campaign: {
          title: "Hard to Kill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Hard to Kill")
    end

    it "can't update a campaign you're just a player in" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")
      @alice = User.create!(email: "alice@example.com", confirmed_at: Time.now)
      @campaign.players << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      patch "/api/v1/campaigns/#{@campaign.id}", headers: @headers, params: {
        campaign: {
          title: "Hard to Change"
        }
      }
      expect(response).to have_http_status(:forbidden)
      expect(@campaign.reload.title).to eq("Action Movie")
    end
  end

  describe "DELETE /campaigns/:id" do
    it "destroys campaign" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")
      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Campaign.find_by(id: @campaign.id)).to be_nil
    end

    it "can't destroy a campaign you're just a player in" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")
      @alice = User.create!(email: "alice@example.com", confirmed_at: Time.now)
      @campaign.players << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:forbidden)
      expect(@campaign.reload).to be_present
    end

    it "even for a gamemaster, can't destroy a campaign you're a player in" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")
      @gm_alice = User.create!(email: "alice@example.com", gamemaster: true, confirmed_at: Time.now)
      @campaign.players << @gm_alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @gm_alice)

      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:not_found)
      expect(@campaign.reload).to be_present
    end
  end

  describe "POST /set" do
    it "returns http success" do
      @campaign = @gamemaster.campaigns.create!(title: "Action Movie")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@gamemaster.id}"))
      expect(user_info["campaign_id"]).to eq(@campaign.id)
    end

    it "clears current campaign" do
      post "/api/v1/campaigns/current", params: { id: nil }, headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@gamemaster.id}"))
      expect(user_info["campaign_id"]).to eq(nil)
    end

    it "can't set other users' campaigns" do
      @gamemaster = User.create!(email: "someone@else.com", confirmed_at: Time.now)
      @campaign = @gamemaster.campaigns.create!(title: "Adventure")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "can set campaign you're a player in" do
      @campaign = @gamemaster.campaigns.create!(title: "Adventure")
      @alice = User.create!(email: "alice@example.com", confirmed_at: Time.now)
      @campaign.players << @alice

      @headers = Devise::JWT::TestHelpers.auth_headers({}, @alice)

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@alice.id}"))
      expect(user_info["campaign_id"]).to eq(@campaign.id)
    end
  end

end
