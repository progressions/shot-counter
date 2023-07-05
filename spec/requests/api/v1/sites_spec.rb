require 'rails_helper'

RSpec.describe "Api::V1::Sites", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:site) { Site.create!(name: "The Site", campaign: action_movie) }
  let(:dragons) { Faction.create!(name: "The Dragons", campaign: action_movie) }
  let!(:baseball_field) { Site.create!(name: "Baseball Field", campaign: action_movie) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/sites", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"][0]["name"]).to eq("The Site")
    end

    it "returns all sites that are not the current character's site" do
      brick.sites << site

      get "/api/v1/sites", headers: headers, params: { character_id: brick.id }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].length).to eq(1)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/sites/#{site.id}", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Site")
    end
  end

  describe "POST /create" do
    it "creates a site" do
      post "/api/v1/sites", params: { site: { name: "The Site" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Site")
    end

    it "creates a site with a faction" do
      post "/api/v1/sites", params: { site: { name: "The Site", faction_id: dragons.id } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Site")
      expect(body["faction"]["name"]).to eq(dragons.name)
    end
  end

  describe "PUT /update" do
    it "updates a site" do
      put "/api/v1/sites/#{site.id}", params: { site: { name: "The Best Site" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Best Site")
    end

    it "adds a faction to a site" do
      put "/api/v1/sites/#{site.id}", params: { site: { faction_id: dragons.id } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Site")
      expect(body["faction"]["name"]).to eq(dragons.name)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      expect {
        delete "/api/v1/sites/#{site.id}", headers: headers
      }.to change { Site.count }.by(-1)
    end
  end
end
