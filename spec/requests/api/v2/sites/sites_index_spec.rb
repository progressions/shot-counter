require "rails_helper"
RSpec.describe "Api::V2::Sites", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")

    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")

    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")

    # sites
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", description: "The Dragons' headquarters.", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", description: "The Ascended's headquarters.", faction_id: @ascended.id, juncture_id: @modern.id)
    @bandit_hideout = @campaign.sites.create!(name: "Bandit Hideout", description: "Where the bandits hang out.", faction_id: nil, juncture_id: @ancient.id)
    @stone_circle = @campaign.sites.create!(name: "Stone Circle", description: "An ancient stone circle.", faction_id: nil, juncture_id: @ancient.id, active: false)

    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)

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
    @serena = Character.create!(name: "Serena", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @player.id, juncture_id: @ancient.id)

    @brick.sites << @dragons_hq
    @serena.sites << @stone_circle
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    it "gets all sites" do
      get "/api/v2/sites", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "returns site attributes" do
      get "/api/v2/sites", params: { search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].length).to eq(1)
      expect(body["sites"][0]).to include("name" => "Dragons HQ", "faction_id" => @dragons.id, "juncture_id" => @modern.id)
      expect(body["sites"][0].keys).to eq(["id", "name", "description", "active", "created_at", "updated_at", "faction_id", "faction", "campaign_id", "image_url", "juncture_id", "entity_class", "characters", "image_positions"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns an empty array when no sites exist" do
      Attunement.delete_all
      Site.delete_all
      get "/api/v2/sites", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/sites", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ", "Ascended HQ", "Bandit Hideout"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/sites", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @dragons_hq.touch
      get "/api/v2/sites", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ", "Bandit Hideout", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @dragons_hq.touch
      get "/api/v2/sites", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ", "Bandit Hideout", "Ascended HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/sites", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ", "Bandit Hideout", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/sites", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ", "Bandit Hideout", "Ascended HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by id" do
      get "/api/v2/sites", params: { id: @dragons_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/sites", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/sites", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "filters by faction_id" do
      get "/api/v2/sites", params: { faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/sites", params: { faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by juncture_id" do
      get "/api/v2/sites", params: { juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/sites", params: { juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout"])
      expect(body["factions"]).to eq([])
    end

    it "filters by search string" do
      get "/api/v2/sites", params: { search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/sites", params: { search: "Bandit" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout"])
      expect(body["factions"]).to eq([])
    end

    it "gets only active sites when show_hidden is false" do
      get "/api/v2/sites", params: { show_hidden: "false" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["sites"].map { |s| s["name"] }).not_to include("Stone Circle")
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "gets all sites when show_hidden is true" do
      get "/api/v2/sites", params: { show_hidden: "true" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Stone Circle", "Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id __NONE__ for sites with no faction" do
      get "/api/v2/sites", params: { faction_id: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout"])
      expect(body["factions"]).to eq([])
    end

    it "filters by juncture_id __NONE__ for sites with no juncture" do
      @mystic_site = @campaign.sites.create!(name: "Mystic Site", description: "A mysterious site.", faction_id: @dragons.id, juncture_id: nil)
      get "/api/v2/sites", params: { juncture_id: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Mystic Site"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns empty array when ids is explicitly empty" do
      get "/api/v2/sites", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"]).to eq([])
      expect(body["factions"]).to eq([])
    end
  end

  describe "GET /autocomplete" do
    it "gets all sites" do
      get "/api/v2/sites", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "returns site attributes" do
      get "/api/v2/sites", params: { autocomplete: true, search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].length).to eq(1)
      expect(body["sites"][0]).to include("name" => "Dragons HQ")
      expect(body["sites"][0].keys).to eq(["id", "name", "entity_class"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "returns an empty array when no sites exist" do
      Attunement.delete_all
      Site.delete_all
      get "/api/v2/sites", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/sites", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ", "Ascended HQ", "Bandit Hideout"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/sites", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @dragons_hq.touch
      get "/api/v2/sites", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ", "Bandit Hideout", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @dragons_hq.touch
      get "/api/v2/sites", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ", "Bandit Hideout", "Ascended HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/sites", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ", "Bandit Hideout", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/sites", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ", "Bandit Hideout", "Ascended HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/sites", params: { autocomplete: true, faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/sites", params: { autocomplete: true, faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/sites", params: { autocomplete: true, search: "Dragons" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/sites", params: { autocomplete: true, search: "Bandit" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout"])
      expect(body["factions"]).to eq([])
    end

    it "filters by juncture_id" do
      get "/api/v2/sites", params: { autocomplete: true, juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/sites", params: { autocomplete: true, juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout"])
      expect(body["factions"]).to eq([])
    end

    it "filters by character_id" do
      get "/api/v2/sites", params: { autocomplete: true, character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by character_id" do
      get "/api/v2/sites", params: { autocomplete: true, character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "gets only active sites when show_hidden is false" do
      get "/api/v2/sites", params: { autocomplete: true, show_hidden: "false" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["sites"].map { |s| s["name"] }).not_to include("Stone Circle")
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "gets all sites when show_hidden is true" do
      get "/api/v2/sites", params: { autocomplete: true, show_hidden: "true" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["sites"].map { |s| s["name"] }).to eq(["Stone Circle", "Bandit Hideout", "Ascended HQ", "Dragons HQ"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
  end
end
