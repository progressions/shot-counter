require 'rails_helper'

RSpec.describe "Api::V1::Campaigns", type: :request do
  before(:each) do
    @user = User.create!(email: "email@example.com")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @user)
  end

  describe "GET /campaigns" do
    it "returns campaigns" do
      @action_movie = @user.campaigns.create!(title: "Action Movie")
      @adventure = @user.campaigns.create!(title: "Adventure")

      get "/api/v1/campaigns", headers: @headers
      expect(response).to have_http_status(:success)
      campaigns = JSON.parse(response.body)
      expect(campaigns.map { |c| c["title"] }).to eq(["Action Movie", "Adventure"])
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
    it "fetches campaign" do
      @campaign = @user.campaigns.create!(title: "Action Movie")

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
      @campaign = @user.campaigns.create!(title: "Action Movie")
      patch "/api/v1/campaigns/#{@campaign.id}", headers: @headers, params: {
        campaign: {
          title: "Hard to Kill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Hard to Kill")
    end
  end

  describe "DESTROY /campaigns/:id" do
    it "destroys campaign" do
      @campaign = @user.campaigns.create!(title: "Action Movie")
      delete "/api/v1/campaigns/#{@campaign.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Campaign.find_by(id: @campaign.id)).to be_nil
    end
  end

  describe "POST /set" do
    it "returns http success" do
      @campaign = @user.campaigns.create!(title: "Action Movie")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@user.id}"))
      expect(user_info["campaign_id"]).to eq(@campaign.id)
    end

    it "clears current campaign" do
      post "/api/v1/campaigns/current", params: { id: nil }, headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@user.id}"))
      expect(user_info["campaign_id"]).to eq(nil)
    end

    it "can't set other users' campaigns" do
      @user = User.create!(email: "someone@else.com")
      @campaign = @user.campaigns.create!(title: "Adventure")

      post "/api/v1/campaigns/current", params: { id: @campaign.id }, headers: @headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

end
