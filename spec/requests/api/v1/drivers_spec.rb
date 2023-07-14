require "rails_helper"

RSpec.describe "Api::V1::Actors", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:serena) { Vehicle.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:brick) { Vehicle.create!(name: "Brick Manly", campaign: action_movie) }
  let(:shing) { Vehicle.create!(name: "Ugly Shing", campaign: action_movie) }
  let(:grunts) { Vehicle.create!(name: "Grunts", action_values: { "Type" => "Mook", "Chase Points" => 25 }, campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:fight) { action_movie.fights.create!(name: "Fight") }
  let!(:fight_brick) { Shot.create!(fight: fight, vehicle: brick, shot: 10) }
  let!(:fight_shing) { Shot.create!(fight: fight, vehicle: shing, shot: 15) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /api/v1/fights/:fight_id/drivers" do
    it "returns a list of drivers" do
      get "/api/v1/fights/#{fight.id}/drivers", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body.map { |a| a["name"] }).to eq(["Brick Manly", "Ugly Shing"])
    end
  end

  describe "POST /api/v1/fights/:id/drivers/:vehicle_id/add" do
    it "adds a vehicle to a fight" do
      post "/api/v1/fights/#{fight.id}/drivers/#{serena.id}/add", headers: headers, params: { vehicle: { current_shot: 12 } }

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Serena Tessaro")
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Brick Manly", "Serena Tessaro", "Ugly Shing"])
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
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Brick Manly", "Grunts", "Ugly Shing"])
    end
  end

  describe "POST /api/v1/fights/:id/drivers/:vehicle_id/act" do
    it "acts a vehicle" do
      patch "/api/v1/fights/#{fight.id}/drivers/#{brick.id}/act", headers: headers, params: { shots: 3 }

      expect(response).to have_http_status(200)
      expect(fight_brick.reload.shot).to eq(7)
    end
  end

  describe "GET /api/v1/fights/:id/drivers/:vehicle_id" do
    it "returns a vehicle" do
      get "/api/v1/fights/#{fight.id}/drivers/#{brick.id}", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
    end
  end

  describe "PATCH /api/v1/fights/:id/drivers/:vehicle_id/reveal" do
    it "reveals a vehicle" do
      fight_brick.update(shot: nil)
      patch "/api/v1/fights/#{fight.id}/drivers/#{brick.id}/reveal", headers: headers

      expect(response).to have_http_status(200)
      expect(fight_brick.reload.shot).to eq(0)
    end
  end

  describe "PATCH /api/v1/fights/:id/drivers/:vehicle_id/hide" do
    it "hides a vehicle" do
      patch "/api/v1/fights/#{fight.id}/drivers/#{brick.id}/hide", headers: headers

      expect(response).to have_http_status(200)
      expect(fight_brick.reload.shot).to eq(nil)
    end
  end

  describe "DELETE /api/v1/fights/:id/drivers/:vehicle_id" do
    it "removes a vehicle from a fight" do
      delete "/api/v1/fights/#{fight.id}/drivers/#{brick.id}", headers: headers

      expect(response).to have_http_status(200)
      expect(fight.reload.vehicles.order(:name).map(&:name)).to eq(["Ugly Shing"])
    end
  end
end

