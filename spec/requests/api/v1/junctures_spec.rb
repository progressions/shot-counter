require 'rails_helper'

RSpec.describe "Api::V1::Junctures", type: :request do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:juncture) { Juncture.create!(name: "The Juncture", campaign: action_movie, active: true) }
  let(:dragons) { Faction.create!(name: "The Dragons", campaign: action_movie) }
  let!(:ascended) { Faction.create!(name: "Ascended", campaign: action_movie) }
  let!(:baseball_field) { Juncture.create!(name: "Baseball Field", campaign: action_movie, active: true) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/junctures", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |s| s["name"] }).to eq(["Baseball Field", "The Juncture"])
    end

    it "doesn't return inactive junctures by default" do
      juncture.active = false
      juncture.save!
      get "/api/v1/junctures", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |s| s["name"] }).to eq(["Baseball Field"])
    end

    it "doesn't return inactive junctures for a player" do
      juncture.active = false
      juncture.save!
      get "/api/v1/junctures?hidden=false", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |s| s["name"] }).to eq(["Baseball Field"])
    end

    it "returns inactive junctures for a gamemaster" do
      juncture.active = false
      juncture.save!
      user.gamemaster = true
      user.save!
      get "/api/v1/junctures?hidden=true", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |s| s["name"] }).to eq(["Baseball Field", "The Juncture"])
    end

    it "returns all junctures that are not the current character's juncture" do
      brick.juncture = juncture
      brick.save

      get "/api/v1/junctures", headers: headers, params: { character_id: brick.id }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].length).to eq(1)
    end

    it "returns junctures matching a search string" do
      get "/api/v1/junctures", headers: headers, params: { search: "Baseball" }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"][0]["name"]).to eq("Baseball Field")
    end

    it "returns junctures by faction_id" do
      juncture.update(faction: dragons)
      get "/api/v1/junctures", headers: headers, params: { faction_id: dragons.id }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |s| s["name"] }).to eq(["The Juncture"])
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/junctures/#{juncture.id}", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Juncture")
    end
  end

  describe "POST /create" do
    it "creates a juncture" do
      post "/api/v1/junctures", params: { juncture: { name: "The New Juncture" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The New Juncture")
    end

    it "creates a juncture with a faction" do
      post "/api/v1/junctures", params: { juncture: { name: "The New Juncture", faction_id: dragons.id } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The New Juncture")
      expect(body["faction"]["name"]).to eq(dragons.name)
    end
  end

  describe "PUT /update" do
    it "updates a juncture" do
      put "/api/v1/junctures/#{juncture.id}", params: { juncture: { name: "The Best Juncture" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Best Juncture")
    end

    it "adds a faction to a juncture" do
      put "/api/v1/junctures/#{juncture.id}", params: { juncture: { faction_id: dragons.id } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Juncture")
      expect(body["faction"]["name"]).to eq(dragons.name)
    end

    it "updates active flag" do
      put "/api/v1/junctures/#{juncture.id}", params: { juncture: { active: false } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Juncture")
      expect(body["active"]).to eq(false)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      expect {
        delete "/api/v1/junctures/#{juncture.id}", headers: headers
      }.to change { Juncture.count }.by(-1)
    end
  end
end
