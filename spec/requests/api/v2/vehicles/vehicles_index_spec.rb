require "rails_helper"

RSpec.describe "Api::V2::Vehicles", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")

    @campaign = @gamemaster.campaigns.create!(name: "Adventure")

    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")

    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)

    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")

    # fight
    @fight = @campaign.fights.create!(name: "Big Brawl")

    # vehicles
    @car = @campaign.vehicles.create!(name: "Car", faction_id: @dragons.id, user_id: @player.id, action_values: { Type: "PC", Archetype: "Car" }, juncture_id: @modern.id)
    @tank = @campaign.vehicles.create!(name: "Tank", faction_id: @ascended.id, user_id: @player.id, action_values: { Type: "Boss", Archetype: "Tank" })
    @bike = @campaign.vehicles.create!(name: "Bike", faction_id: @dragons.id, user_id: @player.id, action_values: { Type: "Mook", Archetype: "Bicycle" }, juncture_id: @ancient.id)
    @plane = @campaign.vehicles.create!(name: "Plane", faction_id: @ascended.id, user_id: @player.id, action_values: { Type: "Ally", Archetype: "Airplane" })
    @van = @campaign.vehicles.create!(name: "Van", faction_id: @ascended.id, user_id: @gamemaster.id, action_values: { Type: "Featured Foe", Archetype: "Van" })
    @dead_vehicle = @campaign.vehicles.create!(name: "Dead Car", faction_id: @dragons.id, user_id: @player.id, action_values: { Type: "PC", Archetype: "Car" }, juncture_id: @modern.id, active: false)

    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    it "gets all vehicles" do
      get "/api/v2/vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Plane", "Bike", "Tank", "Car"])
    end

    it "returns vehicle attributes" do
      get "/api/v2/vehicles", params: { search: "Car" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].length).to eq(1)
      expect(body["vehicles"][0]).to include("name" => "Car", "faction_id" => @dragons.id, "entity_class" => "Vehicle")
      expect(body["vehicles"][0].keys).to eq(["id", "name", "action_values", "created_at", "updated_at", "image_url", "description", "entity_class", "faction_id", "faction", "image_positions"])
    end

    it "returns an empty array when no vehicles exist" do
      Vehicle.delete_all
      get "/api/v2/vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/vehicles", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Tank", "Bike", "Plane", "Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/vehicles", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Plane", "Bike", "Tank", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @car.touch
      get "/api/v2/vehicles", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Tank", "Bike", "Plane", "Van", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @car.touch
      get "/api/v2/vehicles", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Van", "Plane", "Bike", "Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/vehicles", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Bike", "Car", "Plane", "Tank", "Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/vehicles", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Tank", "Plane", "Car", "Bike"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type ascending" do
      get "/api/v2/vehicles", params: { sort: "type", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane", "Tank", "Van", "Bike", "Car"])
      expect(body["vehicles"].map { |c| c["action_values"]["Type"] }).to eq(["Ally", "Boss", "Featured Foe", "Mook", "PC"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type descending" do
      get "/api/v2/vehicles", params: { sort: "type", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Bike", "Van", "Tank", "Plane"])
      expect(body["vehicles"].map { |c| c["action_values"]["Type"] }).to eq(["PC", "Mook", "Featured Foe", "Boss", "Ally"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype ascending" do
      get "/api/v2/vehicles", params: { sort: "archetype", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane", "Bike", "Car", "Tank", "Van"])
      expect(body["vehicles"].map { |c| c["action_values"]["Archetype"] }).to eq(["Airplane", "Bicycle", "Car", "Tank", "Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype descending" do
      get "/api/v2/vehicles", params: { sort: "archetype", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Tank", "Car", "Bike", "Plane"])
      expect(body["vehicles"].map { |c| c["action_values"]["Archetype"] }).to eq( ["Van", "Tank", "Car", "Bicycle", "Airplane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by id" do
      get "/api/v2/vehicles", params: { id: @car.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by ids" do
      get "/api/v2/vehicles", params: { ids: [@car.id, @tank.id].join(",") }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Tank", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/vehicles", params: { faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Bike", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/vehicles", params: { faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Plane", "Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by juncture_id" do
      get "/api/v2/vehicles", params: { juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/vehicles", params: { juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Bike"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by user_id" do
      get "/api/v2/vehicles", params: { user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/vehicles", params: { search: "Ca" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/vehicles", params: { search: "lane" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by vehicle type" do
      get "/api/v2/vehicles", params: { vehicle_type: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by vehicle vehicle_type" do
      get "/api/v2/vehicles", params: { vehicle_type: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by archetype" do
      get "/api/v2/vehicles", params: { archetype: "Airplane" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by archetype" do
      get "/api/v2/vehicles", params: { archetype: "Car" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @dragons_party.vehicles << @car
      get "/api/v2/vehicles", params: { party_id: @dragons_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @ascended_party.vehicles << @tank
      @ascended_party.vehicles << @bike
      get "/api/v2/vehicles", params: { party_id: @ascended_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Bike", "Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by fight" do
      @fight.vehicles << @car
      @fight.vehicles << @tank
      get "/api/v2/vehicles", params: { sort: "name", order: "asc", fight_id: @fight.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
  end
end
