require 'rails_helper'

RSpec.describe "Api::V1::Memberships", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:serena) { Character.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:truck) { Vehicle.create!(name: "Truck", campaign: action_movie) }
  let!(:party) { Party.create!(name: "The Party", campaign: action_movie) }
  let!(:other_party) { Party.create!(name: "The Other Party", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  before(:each) do
    set_current_campaign(user, action_movie)
    party.characters << brick
  end

  describe "GET /index" do
    it "returns memberships" do
      get "/api/v1/parties/#{party.id}/memberships", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].length).to eq(1)
      expect(body["vehicles"].length).to eq(0)
      expect(body["characters"][0]["name"]).to eq("Brick Manly")
    end
  end

  describe "POST /create" do
    it "adds a character to a party" do
      expect {
        post "/api/v1/parties/#{party.id}/memberships", params: { character_id: serena.id }, headers: headers
      }.to change { party.characters.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to match_array(["Brick Manly", "Serena Tessaro"])
    end

    it "adds a vehicle to a party" do
      expect {
        post "/api/v1/parties/#{party.id}/memberships", params: { vehicle_id: truck.id }, headers: headers
      }.to change { party.vehicles.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"][0]["name"]).to eq("Truck")
    end

    it "adds a character to a different party" do
      expect {
        post "/api/v1/parties/#{other_party.id}/memberships", params: { character_id: brick.id }, headers: headers
      }.to change { other_party.characters.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"][0]["name"]).to eq("Brick Manly")
    end

    it "adds a vehicle to a different party" do
      expect {
        post "/api/v1/parties/#{other_party.id}/memberships", params: { vehicle_id: truck.id }, headers: headers
      }.to change { other_party.vehicles.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"][0]["name"]).to eq("Truck")
    end
  end

  describe "DELETE /destroy" do
    it "removes a character from a party" do
      expect {
        delete "/api/v1/parties/#{party.id}/memberships/#{brick.id}/character", headers: headers
      }.to change { party.characters.count }.by(-1)
      expect(response).to have_http_status(:success)
      expect(brick.reload).to eq(brick)
    end

    it "removes a vehicle from a party" do
      party.vehicles << truck
      expect {
        delete "/api/v1/parties/#{party.id}/memberships/#{truck.id}/vehicle", headers: headers
      }.to change { party.vehicles.count }.by(-1)
      expect(response).to have_http_status(:success)
      expect(truck.reload).to eq(truck)
    end
  end
end
