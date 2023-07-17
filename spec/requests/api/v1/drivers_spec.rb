require "rails_helper"

RSpec.describe "Api::V1::Actors", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:serena) { Vehicle.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:truck) { Vehicle.create!(name: "Truck Manly", campaign: action_movie) }
  let(:shing) { Vehicle.create!(name: "Ugly Shing", campaign: action_movie) }
  let(:grunts) { Vehicle.create!(name: "Grunts", action_values: { "Type" => "Mook", "Chase Points" => 25 }, campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:fight) { action_movie.fights.create!(name: "Fight") }
  let!(:truck_shot) { Shot.create!(fight: fight, vehicle: truck, shot: 10) }
  let!(:shing_shot) { Shot.create!(fight: fight, vehicle: shing, shot: 15) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /api/v1/fights/:fight_id/drivers" do
    it "returns a list of drivers" do
      get "/api/v1/fights/#{fight.id}/drivers", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body.map { |a| a["name"] }).to eq(["Truck Manly", "Ugly Shing"])
    end
  end

  describe "POST /api/v1/fights/:id/drivers/:vehicle_id/add" do
    it "adds a vehicle to a fight" do
      post "/api/v1/fights/#{fight.id}/drivers/#{serena.id}/add", headers: headers, params: { vehicle: { current_shot: 12 } }

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Serena Tessaro")
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Serena Tessaro", "Truck Manly", "Ugly Shing"])
    end

    it "adds a vehicle to a fight with a driver" do
      post "/api/v1/fights/#{fight.id}/drivers/#{serena.id}/add", headers: headers, params: { vehicle: { current_shot: 12, driver: { id: brick.id } } }

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Serena Tessaro")
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Serena Tessaro", "Truck Manly", "Ugly Shing"])
      expect(body["driver"]["name"]).to eq("Brick Manly")
    end

    it "adds a mook to a fight" do
      post "/api/v1/fights/#{fight.id}/drivers/#{grunts.id}/add", headers: headers, params: { vehicle: { current_shot: 20, color: "red" } }

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Grunts")
      expect(body["color"]).to eq("red")
      shot = Shot.find(body["shot_id"])
      expect(shot.count).to eq(25)
      expect(shot.color).to eq("red")
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Grunts", "Truck Manly", "Ugly Shing"])
    end
  end

  describe "POST /api/v1/fights/:id/drivers/:vehicle_id/act" do
    it "acts a vehicle" do
      patch "/api/v1/fights/#{fight.id}/drivers/#{truck.id}/act", headers: headers, params: { shots: 3, vehicle: { shot_id: truck_shot.id } }

      expect(response).to have_http_status(200)
      expect(truck_shot.reload.shot).to eq(7)
    end
  end

  describe "GET /api/v1/fights/:id/drivers/:vehicle_id" do
    it "returns a vehicle" do
      get "/api/v1/fights/#{fight.id}/drivers/#{truck.id}", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Truck Manly")
    end
  end

  describe "PATCH /api/v1/fights/:id/drivers/:vehicle_id" do
    it "changes the name of a vehicle" do
      patch "/api/v1/fights/#{fight.id}/drivers/#{truck.id}", headers: headers, params: { vehicle: { name: "Truck" } }

      expect(response).to have_http_status(200)
      expect(truck.reload.name).to eq("Truck")
    end

    it "adds a driver to a vehicle" do
      patch "/api/v1/fights/#{fight.id}/drivers/#{truck.id}",
        headers: headers,
        params: { vehicle: { shot_id: truck_shot.id, driver: { id: brick.id } } }

      expect(response).to have_http_status(200)
      expect(truck_shot.reload.driver).to eq(brick)
    end
  end

  describe "PATCH /api/v1/fights/:id/drivers/:vehicle_id/reveal" do
    it "reveals a vehicle" do
      truck_shot.update(shot: nil)
      patch "/api/v1/fights/#{fight.id}/drivers/#{truck.id}/reveal",
        headers: headers,
        params: { vehicle: { shot_id: truck_shot.id } }

      expect(response).to have_http_status(200)
      expect(truck_shot.reload.shot).to eq(0)
    end
  end

  describe "PATCH /api/v1/fights/:id/drivers/:vehicle_id/hide" do
    it "hides a vehicle" do
      patch "/api/v1/fights/#{fight.id}/drivers/#{truck.id}/hide", headers: headers, params: { vehicle: { shot_id: truck_shot.id } }

      expect(response).to have_http_status(200)
      expect(truck_shot.reload.shot).to eq(nil)
    end
  end

  describe "DELETE /api/v1/fights/:id/drivers/:vehicle_id" do
    it "removes a vehicle from a fight" do
      delete "/api/v1/fights/#{fight.id}/drivers/#{truck_shot.id}", headers: headers

      expect(response).to have_http_status(200)
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Ugly Shing"])
    end
  end
end

