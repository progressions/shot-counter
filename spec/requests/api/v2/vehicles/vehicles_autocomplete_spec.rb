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

  describe "GET autocomplete" do
    it "gets all vehicles" do
      get "/api/v2/vehicles", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Plane", "Bike", "Tank", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "returns vehicle attributes" do
      get "/api/v2/vehicles", params: { autocomplete: true, search: "Car" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].length).to eq(1)
      expect(body["vehicles"][0]).to include("name" => "Car")
      expect(body["vehicles"][0].keys).to eq(["id", "name"])
    end

    it "returns an empty array when no vehicles exist" do
      Vehicle.delete_all
      get "/api/v2/vehicles", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Tank", "Bike", "Plane", "Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Plane", "Bike", "Tank", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @car.touch
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Tank", "Bike", "Plane", "Van", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @car.touch
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Van", "Plane", "Bike", "Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Bike", "Car", "Plane", "Tank", "Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Tank", "Plane", "Car", "Bike"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type ascending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "type", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq( ["Plane", "Tank", "Van", "Bike", "Car"])
      expect(body["vehicles"].map { |c| c["action_values"] }.compact).to eq([])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type descending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "type", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Bike", "Van", "Tank", "Plane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype ascending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "archetype", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane", "Bike", "Car", "Tank", "Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype descending" do
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "archetype", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van", "Tank", "Car", "Bike", "Plane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/vehicles", params: { autocomplete: true, faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq( ["Bike", "Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by user_id" do
      get "/api/v2/vehicles", params: { autocomplete: true, user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Van"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/vehicles", params: { autocomplete: true, search: "lane" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/vehicles", params: { autocomplete: true, search: "Car" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by vehicle type" do
      get "/api/v2/vehicles", params: { autocomplete: true, vehicle_type: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by vehicle vehicle_type" do
      get "/api/v2/vehicles", params: { autocomplete: true, vehicle_type: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq( ["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by archetype" do
      get "/api/v2/vehicles", params: { autocomplete: true, archetype: "Airplane" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by archetype" do
      get "/api/v2/vehicles", params: { autocomplete: true, archetype: "Car" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @dragons_party.vehicles << @car
      get "/api/v2/vehicles", params: { autocomplete: true, party_id: @dragons_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @ascended_party.vehicles << @plane
      @ascended_party.vehicles << @bike
      get "/api/v2/vehicles", params: { autocomplete: true, party_id: @ascended_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Plane", "Bike"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by fight" do
      @fight.vehicles << @car
      @fight.vehicles << @tank
      @fight.vehicles << @plane
      get "/api/v2/vehicles", params: { autocomplete: true, sort: "name", order: "asc", fight_id: @fight.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |c| c["name"] }).to eq(["Car", "Plane", "Tank"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "gets only active vehicles when show_all is false" do
      get "/api/v2/vehicles", params: { show_all: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |f| f["name"] }).to eq(["Van", "Plane", "Bike", "Tank", "Car"])
      expect(body["vehicles"].map { |f| f["name"] }).not_to include("Dead Car")
    end

    it "gets all vehicles when show_all is true" do
      get "/api/v2/vehicles", params: { show_all: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["vehicles"].map { |f| f["name"] }).to eq(["Dead Car", "Van", "Plane", "Bike", "Tank", "Car"])
    end
  end
end
