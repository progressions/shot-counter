require "rails_helper"
RSpec.describe "Api::V2::Junctures", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.", faction_id: @dragons.id, active: true)
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.", faction_id: @ascended.id, active: true)
    @future = @campaign.junctures.create!(name: "Future", description: "A futuristic era.", faction_id: @dragons.id, active: true)
    @inactive_juncture = @campaign.junctures.create!(name: "Inactive Juncture", description: "A retired era.", faction_id: @ascended.id, active: false)
    # fight
    @fight = @campaign.fights.create!(name: "Big Brawl")
    # characters
    @bandit = Character.create!(name: "Bandit", action_values: { "Type" => "PC", "Archetype" => "Bandit" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Martial Arts" => 13, "MainAttack" => "Martial Arts" },
      description: { "Appearance" => "He's Beretta 92FS, son" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      juncture_id: @modern.id,
      user_id: @player.id,
    )
    @serena = Character.create!(
      name: "Serena",
      action_values: { "Type" => "PC", "Archetype" => "Sorcerer" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      juncture_id: @ancient.id,
      user_id: @player.id,
    )
    # vehicles
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id, juncture_id: @modern.id)
    @jet = @campaign.vehicles.create!(name: "Jet", campaign_id: @campaign.id, faction_id: @ascended.id, juncture_id: @ancient.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    it "gets all junctures" do
      get "/api/v2/junctures", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Ancient", "Modern"])
    end

    it "returns juncture attributes" do
      get "/api/v2/junctures", params: { search: "Modern" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].length).to eq(1)
      expect(body["junctures"][0]).to include("name" => "Modern", "description" => "The modern world.", "faction_id" => @dragons.id)
      expect(body["junctures"][0].keys).to eq( ["id", "name", "description", "created_at", "updated_at", "faction_id", "campaign_id", "image_url", "faction", "image_positions"])
    end

    it "returns an empty array when no junctures exist" do
      Character.delete_all
      Vehicle.delete_all
      Juncture.delete_all
      get "/api/v2/junctures", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/junctures", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern", "Ancient", "Future"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/junctures", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Ancient", "Modern"])
    end

    it "sorts by updated_at ascending" do
      @modern.touch
      get "/api/v2/junctures", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient", "Future", "Modern"])
    end

    it "sorts by updated_at descending" do
      @modern.touch
      get "/api/v2/junctures", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern", "Future", "Ancient"])
    end

    it "sorts by name ascending" do
      get "/api/v2/junctures", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient", "Future", "Modern"])
    end

    it "sorts by name descending" do
      get "/api/v2/junctures", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern", "Future", "Ancient"])
    end

    it "filters by id" do
      get "/api/v2/junctures", params: { id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by character_id" do
      get "/api/v2/junctures", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by character_id" do
      get "/api/v2/junctures", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient"])
    end

    it "filters by faction_id" do
      get "/api/v2/junctures", params: { faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Modern"])
    end

    it "filters by faction_id" do
      get "/api/v2/junctures", params: { faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient"])
    end

    it "filters by search string" do
      get "/api/v2/junctures", params: { search: "Modern" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by search string" do
      get "/api/v2/junctures", params: { search: "Future" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future"])
    end

    it "gets only active junctures when show_all is false" do
      get "/api/v2/junctures", params: { show_all: "false" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Ancient", "Modern"])
      expect(body["junctures"].map { |j| j["name"] }).not_to include("Inactive Juncture")
    end

    it "gets all junctures when show_all is true" do
      get "/api/v2/junctures", params: { show_all: "true" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Inactive Juncture", "Future", "Ancient", "Modern"])
    end
  end

  describe "GET /autocomplete" do
    it "gets all junctures" do
      get "/api/v2/junctures", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Ancient", "Modern"])
    end

    it "returns juncture attributes" do
      get "/api/v2/junctures", params: { autocomplete: true, search: "Modern" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].length).to eq(1)
      expect(body["junctures"][0]).to include("name" => "Modern")
      expect(body["junctures"][0].keys).to eq(["id", "name"])
    end

    it "returns an empty array when no junctures exist" do
      Character.delete_all
      Vehicle.delete_all
      Juncture.delete_all
      get "/api/v2/junctures", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/junctures", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern", "Ancient", "Future"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/junctures", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Ancient", "Modern"])
    end

    it "sorts by updated_at ascending" do
      @modern.touch
      get "/api/v2/junctures", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient", "Future", "Modern"])
    end

    it "sorts by updated_at descending" do
      @modern.touch
      get "/api/v2/junctures", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern", "Future", "Ancient"])
    end

    it "sorts by name ascending" do
      get "/api/v2/junctures", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient", "Future", "Modern"])
    end

    it "sorts by name descending" do
      get "/api/v2/junctures", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern", "Future", "Ancient"])
    end

    it "filters by id" do
      get "/api/v2/junctures", params: { autocomplete: true, id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by search string" do
      get "/api/v2/junctures", params: { autocomplete: true, search: "Modern" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by search string" do
      get "/api/v2/junctures", params: { autocomplete: true, search: "Future" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future"])
    end

    it "filters by character_id" do
      get "/api/v2/junctures", params: { autocomplete: true, character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by character_id" do
      get "/api/v2/junctures", params: { autocomplete: true, character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient"])
    end

    it "filters by vehicle_id" do
      get "/api/v2/junctures", params: { autocomplete: true, vehicle_id: @tank.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Modern"])
    end

    it "filters by vehicle_id" do
      get "/api/v2/junctures", params: { autocomplete: true, vehicle_id: @jet.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient"])
    end

    it "filters by faction_id" do
      get "/api/v2/junctures", params: { autocomplete: true, faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Future", "Modern"])
    end

    it "filters by faction_id" do
      get "/api/v2/junctures", params: { autocomplete: true, faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"].map { |j| j["name"] }).to eq(["Ancient"])
    end
  end
end
