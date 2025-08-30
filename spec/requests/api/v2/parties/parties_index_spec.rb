require "rails_helper"
RSpec.describe "Api::V2::Parties", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")
    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", description: "The Dragons' main group.", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", description: "The Ascended's elite team.", faction_id: @ascended.id, juncture_id: @modern.id)
    @rogue_team = @campaign.parties.create!(name: "Rogue Team", description: "A group of independents.", faction_id: nil, juncture_id: @ancient.id)
    @inactive_team = @campaign.parties.create!(name: "Inactive Team", description: "A retired group.", faction_id: nil, juncture_id: @ancient.id, active: false)
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
    @brick.parties << @dragons_party
    @serena.parties << @inactive_team
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    it "gets all parties" do
      get "/api/v2/parties", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "returns party attributes" do
      get "/api/v2/parties", params: { search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].length).to eq(1)
      expect(body["parties"][0]).to include("name" => "Dragons Party", "faction_id" => @dragons.id, "juncture_id" => @modern.id)
      expect(body["parties"][0].keys).to eq(["id", "name", "description", "active", "created_at", "updated_at", "faction_id", "campaign_id", "image_url", "juncture_id", "entity_class", "characters", "vehicles", "faction", "juncture", "image_positions"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns an empty array when no parties exist" do
      Membership.delete_all
      Party.delete_all
      get "/api/v2/parties", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/parties", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party", "Ascended Party", "Rogue Team"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/parties", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @dragons_party.touch
      get "/api/v2/parties", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party", "Rogue Team", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @dragons_party.touch
      get "/api/v2/parties", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party", "Rogue Team", "Ascended Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/parties", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party", "Dragons Party", "Rogue Team"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/parties", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Dragons Party", "Ascended Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by id" do
      get "/api/v2/parties", params: { id: @dragons_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/parties", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/parties", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "filters by faction_id" do
      get "/api/v2/parties", params: { faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/parties", params: { faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by juncture_id" do
      get "/api/v2/parties", params: { juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/parties", params: { juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team"])
      expect(body["factions"]).to eq([])
    end

    it "filters by search string" do
      get "/api/v2/parties", params: { search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/parties", params: { search: "Rogue" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team"])
      expect(body["factions"]).to eq([])
    end

    it "gets only active parties when show_hidden is false" do
      get "/api/v2/parties", params: { show_hidden: "false" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Ascended Party", "Dragons Party"])
      expect(body["parties"].map { |p| p["name"] }).not_to include("Inactive Team")
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "gets all parties when show_hidden is true" do
      get "/api/v2/parties", params: { show_hidden: "true" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Inactive Team", "Rogue Team", "Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id __NONE__ for parties with no faction" do
      get "/api/v2/parties", params: { faction_id: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team"])
      expect(body["factions"]).to eq([])
    end

    it "filters by juncture_id __NONE__ for parties with no juncture" do
      @wandering_group = @campaign.parties.create!(name: "Wandering Group", description: "A group between junctures.", faction_id: @dragons.id, juncture_id: nil)
      get "/api/v2/parties", params: { juncture_id: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Wandering Group"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns empty array when ids is explicitly empty" do
      get "/api/v2/parties", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
      expect(body["factions"]).to eq([])
    end
  end

  describe "GET /autocomplete" do
    it "gets all parties" do
      get "/api/v2/parties", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "returns party attributes" do
      get "/api/v2/parties", params: { autocomplete: true, search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].length).to eq(1)
      expect(body["parties"][0]).to include("name" => "Dragons Party")
      expect(body["parties"][0].keys).to eq(["id", "name", "entity_class", "character_ids", "vehicle_ids"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns an empty array when no parties exist" do
      Membership.delete_all
      Party.delete_all
      get "/api/v2/parties", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/parties", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party", "Ascended Party", "Rogue Team"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/parties", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @dragons_party.touch
      get "/api/v2/parties", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party", "Rogue Team", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @dragons_party.touch
      get "/api/v2/parties", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party", "Rogue Team", "Ascended Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/parties", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party", "Dragons Party", "Rogue Team"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/parties", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team", "Dragons Party", "Ascended Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/parties", params: { autocomplete: true, faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/parties", params: { autocomplete: true, faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/parties", params: { autocomplete: true, search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/parties", params: { autocomplete: true, search: "Rogue" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team"])
      expect(body["factions"]).to eq([])
    end

    it "filters by juncture_id" do
      get "/api/v2/parties", params: { autocomplete: true, juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Ascended Party", "Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/parties", params: { autocomplete: true, juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Rogue Team"])
      expect(body["factions"]).to eq([])
    end

    it "filters by character_id" do
      get "/api/v2/parties", params: { autocomplete: true, character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/parties", params: { autocomplete: true, character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
      expect(body["factions"]).to eq([])
    end
  end

  describe "IDs filtering and caching" do
    it "filters by comma-separated ids" do
      get "/api/v2/parties", params: { ids: "#{@dragons_party.id},#{@ascended_party.id}" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to contain_exactly("Dragons Party", "Ascended Party")
    end

    it "filters by array of ids" do
      get "/api/v2/parties", params: { ids: [@dragons_party.id] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].map { |p| p["name"] }).to eq(["Dragons Party"])
    end

    it "returns empty array when ids parameter is empty string" do
      get "/api/v2/parties", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
    end

    it "returns empty array when ids array is empty" do
      get "/api/v2/parties", params: { ids: [] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
    end

    it "filters by single id in array" do
      get "/api/v2/parties", params: { ids: [@dragons_party.id] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].length).to eq(1)
      expect(body["parties"][0]["name"]).to eq("Dragons Party")
    end

    it "returns empty array when ids contain non-existent ids" do
      get "/api/v2/parties", params: { ids: ["non-existent-id-1", "non-existent-id-2"] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"]).to eq([])
    end

    it "caches results with different ids separately" do
      # First request
      get "/api/v2/parties", params: { ids: [@dragons_party.id] }, headers: @headers
      body1 = JSON.parse(response.body)
      
      # Second request with different ids should not return cached result from first
      get "/api/v2/parties", params: { ids: [@ascended_party.id] }, headers: @headers
      body2 = JSON.parse(response.body)
      
      expect(body1["parties"][0]["name"]).to eq("Dragons Party")
      expect(body2["parties"][0]["name"]).to eq("Ascended Party")
    end
  end
end
