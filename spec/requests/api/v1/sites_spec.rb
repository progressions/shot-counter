require 'rails_helper'

RSpec.describe "Api::V1::Sites", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let!(:party) { Party.create!(name: "The Party", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:site) { Site.create!(name: "The Site", campaign: action_movie) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/sites", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body[0]["name"]).to eq("The Site")
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
    it "returns http success" do
      post "/api/v1/sites", params: { site: { name: "The Site" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Site")
    end
  end

  describe "PUT /update" do
    it "returns http success" do
      put "/api/v1/sites/#{site.id}", params: { site: { name: "The Best Site" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Best Site")
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/api/v1/sites/#{site.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(Site.count).to eq(0)
    end
  end
end
