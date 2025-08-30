require "rails_helper"
RSpec.describe "Api::V2::Factions", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    @outlaws = @campaign.factions.create!(name: "The Outlaws", description: "A group of rogues.")
    @inactive_faction = @campaign.factions.create!(name: "Inactive Faction", description: "A retired faction.", active: false)
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", faction_id: @dragons.id)
    @ancient = @campaign.junctures.create!(name: "Ancient", faction_id: @ascended.id)
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
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id)
    @jet = @campaign.vehicles.create!(name: "Jet", campaign_id: @campaign.id, faction_id: @ascended.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    it "gets all factions" do
      get "/api/v2/factions", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "returns faction attributes" do
      get "/api/v2/factions", params: { search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].length).to eq(1)
      expect(body["factions"][0]).to include("name" => "The Dragons", "description" => "A bunch of heroes.")
      expect(body["factions"][0].keys).to eq(["id", "name", "description", "created_at", "updated_at", "image_url", "entity_class", "active", "characters", "vehicles", "junctures"])
    end

    it "returns an empty array when no factions exist" do
      Character.delete_all
      Vehicle.delete_all
      Juncture.delete_all
      Faction.delete_all
      get "/api/v2/factions", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/factions", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons", "The Ascended", "The Outlaws"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/factions", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @dragons.touch
      get "/api/v2/factions", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq( ["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @dragons.touch
      get "/api/v2/factions", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/factions", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons", "The Outlaws"])
    end

    it "sorts by name descending" do
      get "/api/v2/factions", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Dragons", "The Ascended"])
    end

    it "filters by id" do
      get "/api/v2/factions", params: { id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/factions", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/factions", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by vehicle_id" do
      get "/api/v2/factions", params: { vehicle_id: @tank.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by vehicle_id" do
      get "/api/v2/factions", params: { vehicle_id: @jet.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by juncture_id" do
      get "/api/v2/factions", params: { juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/factions", params: { juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/factions", params: { search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/factions", params: { search: "Outlaws" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws"])
    end

    it "gets only active factions when show_hidden is false" do
      get "/api/v2/factions", params: { show_hidden: "false" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
      expect(body["factions"].map { |f| f["name"] }).not_to include("Inactive Faction")
    end

    it "gets all factions when show_hidden is true" do
      get "/api/v2/factions", params: { show_hidden: "true" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["Inactive Faction", "The Outlaws", "The Ascended", "The Dragons"])
    end

    it "returns empty array when ids is explicitly empty" do
      get "/api/v2/factions", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end
  end

  describe "GET /autocomplete" do
    it "gets all factions" do
      get "/api/v2/factions", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "returns faction attributes" do
      get "/api/v2/factions", params: { autocomplete: true, search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].length).to eq(1)
      expect(body["factions"][0]).to include("name" => "The Dragons")
      expect(body["factions"][0].keys).to eq(["id", "name", "entity_class"])
    end

    it "returns an empty array when no factions exist" do
      Character.delete_all
      Vehicle.delete_all
      Juncture.delete_all
      Faction.delete_all
      get "/api/v2/factions", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/factions", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons", "The Ascended", "The Outlaws"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/factions", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @dragons.touch
      get "/api/v2/factions", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @dragons.touch
      get "/api/v2/factions", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/factions", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons", "The Outlaws"])
    end

    it "sorts by name descending" do
      get "/api/v2/factions", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Dragons", "The Ascended"])
    end

    it "filters by id" do
      get "/api/v2/factions", params: { autocomplete: true, id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/factions", params: { autocomplete: true, search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/factions", params: { autocomplete: true, search: "Outlaws" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws"])
    end

    it "filters by character_id" do
      get "/api/v2/factions", params: { autocomplete: true, character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/factions", params: { autocomplete: true, character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by vehicle_id" do
      get "/api/v2/factions", params: { autocomplete: true, vehicle_id: @tank.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by vehicle_id" do
      get "/api/v2/factions", params: { autocomplete: true, vehicle_id: @jet.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by juncture_id" do
      get "/api/v2/factions", params: { autocomplete: true, juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/factions", params: { autocomplete: true, juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "gets only active factions when show_hidden is false" do
      get "/api/v2/factions", params: { autocomplete: true, show_hidden: "false" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Outlaws", "The Ascended", "The Dragons"])
      expect(body["factions"].map { |f| f["name"] }).not_to include("Inactive Faction")
    end

    it "gets all factions when show_hidden is true" do
      get "/api/v2/factions", params: { autocomplete: true, show_hidden: "true" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["Inactive Faction", "The Outlaws", "The Ascended", "The Dragons"])
    end

    it "returns empty array when ids is explicitly empty" do
      get "/api/v2/factions", params: { autocomplete: true, ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end
  end

  describe "IDs filtering and caching" do
    it "filters by comma-separated ids" do
      get "/api/v2/factions", params: { ids: "#{@dragons.id},#{@ascended.id}" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to contain_exactly("The Dragons", "The Ascended")
    end

    it "filters by array of ids" do
      get "/api/v2/factions", params: { ids: [@dragons.id] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns empty array when ids parameter is empty string" do
      get "/api/v2/factions", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end

    it "returns empty array when ids array is empty" do
      get "/api/v2/factions", params: { ids: [] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end

    it "filters by single id in array" do
      get "/api/v2/factions", params: { ids: [@dragons.id] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].length).to eq(1)
      expect(body["factions"][0]["name"]).to eq("The Dragons")
    end

    it "returns empty array when ids contain non-existent ids" do
      get "/api/v2/factions", params: { ids: ["non-existent-id-1", "non-existent-id-2"] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"]).to eq([])
    end

    it "caches results with different ids separately" do
      # First request
      get "/api/v2/factions", params: { ids: [@dragons.id] }, headers: @headers
      body1 = JSON.parse(response.body)
      
      # Second request with different ids should not return cached result from first
      get "/api/v2/factions", params: { ids: [@ascended.id] }, headers: @headers
      body2 = JSON.parse(response.body)
      
      expect(body1["factions"][0]["name"]).to eq("The Dragons")
      expect(body2["factions"][0]["name"]).to eq("The Ascended")
    end
  end
end
