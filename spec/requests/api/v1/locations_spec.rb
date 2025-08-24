require 'rails_helper'

RSpec.describe "Locations", type: :request do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
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

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "POST /create" do
    it "creates a new Location for a character" do
      post "/api/v1/locations", params: {
        shot_id: brick_shot.id,
        location: { name: "Ranch" }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(brick_shot.reload.location).to eq("Ranch")
    end

    it "creates a blank location for a character" do
      post "/api/v1/locations", params: {
        shot_id: serena_shot.id,
        location: { name: "" }
      }, headers: headers
      expect(response).to have_http_status(:created)
      expect(serena_shot.reload.location).to eq("")
    end

    it "creates a new location for a vehicle" do
      post "/api/v1/locations", params: {
        shot_id: truck_shot.id,
        location: { name: "Highway" }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(truck_shot.reload.location).to eq("Highway")
    end

    it "creates a blank location for a vehicle" do
      post "/api/v1/locations", params: {
        shot_id: speedboat_shot.id,
        location: { name: "" }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(speedboat_shot.reload.location).to eq("")
    end

    it "creates a separate location for two instances of the same mook" do
      post "/api/v1/locations", params: {
        shot_id: red_grunts_shot.id,
        location: { name: "Highway" }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(red_grunts_shot.reload.location).to eq("Highway")

      post "/api/v1/locations", params: {
        shot_id: blue_grunts_shot.id,
        location: { name: "Museum" }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(blue_grunts_shot.reload.location).to eq("Museum")
    end
  end
end
