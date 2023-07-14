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
  let(:grunts) { Character.create!(name: "Grunts", action_values: { "Type" => "Mook" }, campaign: action_movie) }

  let!(:serena_shot) { fight.shots.create!(character: serena, shot: 10) }
  let!(:speedboat_shot) { fight.shots.create!(vehicle: speedboat, shot: 10) }
  let!(:brick_shot) { fight.shots.create!(character: brick, shot: 12) }
  let!(:truck_shot) { fight.shots.create!(vehicle: truck, shot: 12) }
  let(:red_grunts_shot) { fight.shots.create!(character: grunts, shot: 10) }
  let(:blue_grunts_shot) { fight.shots.create!(character: grunts, shot: 10) }
  let(:red_mook) { Mook.create!(shot: red_grunts_shot, count: 20, color: "red") }
  let(:blue_mook) { Mook.create!(shot: blue_grunts_shot, count: 15, color: "blue") }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns location for a character's shot" do
      Location.create!(name: "Ranch", shot: brick_shot)
      Location.create!(name: "Highway", shot: truck_shot)

      get "/api/v1/locations", params: { shot_id: brick_shot.id }, headers: headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ranch")
    end

    it "returns location for a vehicle's shot" do
      Location.create!(name: "Ranch", shot: brick_shot)
      Location.create!(name: "Highway", shot: truck_shot)

      get "/api/v1/locations", params: { shot_id: truck_shot.id }, headers: headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Highway")
    end
  end

  describe "POST /create" do
    it "creates a new Location for a character" do
      expect {
        post "/api/v1/locations", params: {
          shot_id: brick_shot.id,
          location: { name: "Ranch" }
        }, headers: headers
      }.to change(Location, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ranch")
      expect(body["shot"]["id"]).to eq(brick_shot.id)
    end

    it "creates a new location for a vehicle" do
      expect {
        post "/api/v1/locations", params: {
          shot_id: truck_shot.id,
          location: { name: "Highway" }
        }, headers: headers
      }.to change(Location, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Highway")
      expect(body["shot"]["id"]).to eq(truck_shot.id)
    end

    it "creates a separate location for two instances of the same mook" do
      red_mook; blue_mook

      expect {
        post "/api/v1/locations", params: {
          shot_id: red_grunts_shot.id,
          location: { name: "Highway" }
        }, headers: headers
      }.to change(Location, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Highway")
      expect(body["shot"]["id"]).to eq(red_grunts_shot.id)

      expect {
        post "/api/v1/locations", params: {
          shot_id: blue_grunts_shot.id,
          location: { name: "Museum" }
        }, headers: headers
      }.to change(Location, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Museum")
      expect(body["shot"]["id"]).to eq(blue_grunts_shot.id)
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
