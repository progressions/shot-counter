require 'rails_helper'

RSpec.describe "Api::V1::Parties", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let!(:party) { Party.create!(name: "The Party", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns parties" do
      get "/api/v1/parties", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body[0]["name"]).to eq("The Party")
    end
  end

  describe "GET /show" do
    it "returns a single party" do
      get "/api/v1/parties/#{party.id}", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Party")
    end
  end

  describe "POST /create" do
    it "creates a party" do
      expect {
        post "/api/v1/parties", params: { party: { name: "The Party" } }, headers: headers
      }.to change { Party.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Party")
    end
  end

  describe "PUT /update" do
    it "updates a party" do
      put "/api/v1/parties/#{party.id}", params: { party: { name: "The Dragons" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Dragons")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a party" do
      expect {
        delete "/api/v1/parties/#{party.id}", headers: headers
      }.to change { Party.count }.by(-1)
      expect(response).to have_http_status(:success)
    end
  end
end
