require 'rails_helper'

RSpec.describe "Vehicles", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now, gamemaster: true) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:dragons) { action_movie.factions.create!(name: "Dragons") }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  context "with a gamemaster" do
    let!(:vehicle) { Vehicle.create!(name: "Batmobile", campaign: action_movie) }

    before(:each) do
      set_current_campaign(user, action_movie)
    end

    describe "GET /index" do
      it "returns all campaign vehicles for a gamemaster" do
        get "/api/v1/vehicles", headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body[0]["name"]).to eq("Batmobile")
      end
    end

    describe "GET /archetypes" do
      it "returns all vehicle archetypes" do
        get "/api/v1/vehicles/archetypes", headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        binding.pry
        expect(body[0]["name"]).to eq("Motorcycle")
      end
    end

    describe "POST /create" do
      it "creates a vehicle" do
        expect {
          post "/api/v1/vehicles", params: { vehicle: { name: "Delorean" } }, headers: headers
        }.to change { Vehicle.count }.by(1)
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Delorean")
      end

      it "creates a task" do
        expect {
          post "/api/v1/vehicles", params: { vehicle: { name: "Catch the Train", task: true } }, headers: headers
        }.to change { Vehicle.count }.by(1)
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Catch the Train")
        expect(body["task"]).to eq(true)
        vehicle = Vehicle.find(body["id"])
        expect(vehicle.task).to eq(true)
      end

      it "creates a vehicle with a faction" do
        expect {
          post "/api/v1/vehicles", params: { vehicle: { name: "Delorean", faction_id: dragons.id } }, headers: headers
        }.to change { Vehicle.count }.by(1)
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Delorean")
        expect(body["faction"]["name"]).to eq("Dragons")
      end
    end

    describe "GET /show" do
      it "returns a vehicle" do
        get "/api/v1/vehicles/#{vehicle.id}", headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Batmobile")
      end
    end

    describe "PATCH /update" do
      it "updates a vehicle" do
        patch "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: { name: "Batmobile 2.0" } }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Batmobile 2.0")
      end

      it "adds a faction" do
        patch "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: { faction_id: dragons.id } }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["faction"]["name"]).to eq("Dragons")
      end
    end

    describe "DELETE /destroy" do
      it "deletes a vehicle" do
        expect {
          delete "/api/v1/vehicles/#{vehicle.id}", headers: headers
        }.to change { Vehicle.count }.by(-1)
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "with a player" do
    let!(:vehicle) { Vehicle.create!(name: "Batmobile", campaign: action_movie) }
    let!(:delorean) { user.vehicles.create!(name: "Delorean", campaign: action_movie) }

    before(:each) do
      user.update(gamemaster: false)
      set_current_campaign(user, action_movie)
    end

    describe "GET /index" do
      it "returns only the user's vehicles for a player" do
        get "/api/v1/vehicles", headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body.length).to eq(1)
        expect(body[0]["name"]).to eq("Delorean")
      end
    end

    describe "POST /create" do
      it "creates a vehicle" do
        expect {
          post "/api/v1/vehicles", params: { vehicle: { name: "Dodge Charger" } }, headers: headers
        }.to change { Vehicle.count }.by(1)
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Dodge Charger")
        expect(user.reload.vehicles.count).to eq(2)
      end
    end

    describe "GET /show" do
      it "returns a vehicle" do
        get "/api/v1/vehicles/#{delorean.id}", headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Delorean")
      end

      it "doesn't return a vehicle that doesn't belong to the user" do
        get "/api/v1/vehicles/#{vehicle.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "PATCH /update" do
      it "updates a vehicle" do
        patch "/api/v1/vehicles/#{delorean.id}", params: { vehicle: { name: "Delorean 2.0" } }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Delorean 2.0")
      end

      it "doesn't update a vehicle that doesn't belong to the user" do
        patch "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: { name: "Batmobile 2.0" } }, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE /destroy" do
      it "deletes a vehicle" do
        expect {
          delete "/api/v1/vehicles/#{delorean.id}", headers: headers
        }.to change { Vehicle.count }.by(-1)
        expect(response).to have_http_status(:success)
      end

      it "doesn't delete a vehicle that doesn't belong to the user" do
        expect {
          delete "/api/v1/vehicles/#{vehicle.id}", headers: headers
        }.to change { Vehicle.count }.by(0)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
