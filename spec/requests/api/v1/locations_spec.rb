require 'rails_helper'

RSpec.describe "Locations", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:fight) { Fight.create!(name: "Museum Fight", campaign: action_movie) }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:serena) { Character.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:truck) { Vehicle.create!(name: "Truck", campaign: action_movie) }
  let(:speedboat) { Vehicle.create!(name: "Speedboat", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  let!(:serena_shot) { fight.shots.create!(character: serena, shot: 10) }
  let!(:speedboat_shot) { fight.shots.create!(vehicle: speedboat, shot: 10) }
  let!(:brick_shot) { fight.shots.create!(character: brick, shot: 12) }
  let!(:truck_shot) { fight.shots.create!(vehicle: truck, shot: 12) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns location for a character's shot" do
      Location.create!(name: "Ranch", shot: brick_shot)
      Location.create!(name: "Highway", shot: truck_shot)

      get "/api/v1/locations", params: { fight_id: fight.id, character_id: brick.id }, headers: headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body.map { |l| l["name"] }).to match_array(["Ranch"])
    end

    it "returns location for a vehicle's shot" do
      Location.create!(name: "Ranch", shot: brick_shot)
      Location.create!(name: "Highway", shot: truck_shot)

      get "/api/v1/locations", params: { fight_id: fight.id, vehicle_id: truck.id }, headers: headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body.map { |l| l["name"] }).to match_array(["Highway"])
    end
  end

  describe "POST /create" do
    it "creates a new Location for a character" do
      expect {
        post "/api/v1/locations", params: {
          fight_id: fight.id,
          character_id: brick.id,
          location: { name: "Ranch" }
        }, headers: headers
      }.to change(Location, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ranch")
      expect(body["shot_id"]).to eq(brick_shot.id)
    end

    it "creates a new location for a vehicle" do
      expect {
        post "/api/v1/locations", params: {
          fight_id: fight.id,
          vehicle_id: truck.id,
          location: { name: "Highway" }
        }, headers: headers
      }.to change(Location, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Highway")
      expect(body["shot_id"]).to eq(truck_shot.id)
    end
  end

  describe "DELETE /destroy" do
    it "deletes a location" do
      location = Location.create!(name: "Ranch", shot: brick_shot)

      expect {
        delete "/api/v1/locations/#{location.id}", headers: headers
      }.to change(Location, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
