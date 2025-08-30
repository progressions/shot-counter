require "rails_helper"
RSpec.describe "Api::V2::Weapons", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # sites
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", description: "The Dragons' headquarters.", faction_id: @dragons.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", description: "The Ascended's headquarters.", faction_id: @ascended.id)
    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")
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
    # weapons
    @beretta = @campaign.weapons.create!(name: "Beretta 92FS", description: "A powerful firearm.", juncture: "Modern", category: "Ranged", damage: 10, concealment: 2, reload_value: 1, mook_bonus: 0, kachunk: false)
    @colt = @campaign.weapons.create!(name: "Colt Python", description: "A classic revolver.", juncture: "Modern", category: "Ranged", damage: 12, concealment: 1, reload_value: 1, mook_bonus: 0, kachunk: false)
    @winchest = @campaign.weapons.create!(name: "Winchester Rifle", description: "A reliable rifle.", juncture: "Past", category: "Ranged", damage: 14, concealment: 4, reload_value: 2, mook_bonus: 0, kachunk: false)
    @sword = @campaign.weapons.create!(name: "Sword", description: "A sharp blade.", juncture: "Ancient", category: "Melee", damage: 8, concealment: nil, reload_value: 0, mook_bonus: 0, kachunk: false)
    @bow = @campaign.weapons.create!(name: "Bow", description: "A long-range weapon.", juncture: "Ancient", category: "Ranged", damage: 6, concealment: 3, reload_value: 1, mook_bonus: 0, kachunk: false)
    @hidden_weapon = @campaign.weapons.create!(name: "Hidden Blade", description: "A concealed weapon.", juncture: "Modern", category: "Melee", damage: 5, concealment: 0, reload_value: 0, mook_bonus: 0, kachunk: false, active: false)
    @brick.weapons << @beretta
    @serena.weapons << @sword
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end
  describe "GET /index" do
    it "gets all weapons" do
      get "/api/v2/weapons", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Bow", "Sword", "Winchester Rifle", "Colt Python", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "returns weapon attributes" do
      get "/api/v2/weapons", params: { search: "Beretta" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(1)
      expect(body["weapons"][0]).to include("name" => "Beretta 92FS", "category" => "Ranged", "juncture" => "Modern", "damage" => 10)
      expect(body["weapons"][0].keys).to eq(["id", "name", "image_url", "created_at", "damage", "concealment", "reload_value", "description", "juncture", "category", "mook_bonus", "kachunk", "entity_class", "image_positions"])
      expect(body["categories"]).to eq(["Ranged"])
      expect(body["junctures"]).to eq(["Modern"])
    end
    it "returns an empty array when no weapons exist" do
      Carry.delete_all
      Weapon.delete_all
      get "/api/v2/weapons", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq([])
      expect(body["categories"]).to eq([])
      expect(body["junctures"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 0,
        "total_count" => 0
      })
    end
    it "filters by comma-separated ids" do
      get "/api/v2/weapons", params: { ids: "#{@beretta.id},#{@sword.id}" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Sword", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern"])
      expect(body["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 2
      )
    end
    it "filters by array of ids" do
      get "/api/v2/weapons", params: { ids: [@beretta.id, @sword.id] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Sword", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern"])
      expect(body["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 2
      )
    end
    it "returns empty array when ids array is empty" do
      get "/api/v2/weapons", params: { ids: [] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq([])
      expect(body["categories"]).to eq([])
      expect(body["junctures"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 0,
        "total_count" => 0
      })
    end
    it "sorts by created_at ascending" do
      get "/api/v2/weapons", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS", "Colt Python", "Winchester Rifle", "Sword", "Bow"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by created_at descending" do
      get "/api/v2/weapons", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Bow", "Sword", "Winchester Rifle", "Colt Python", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by updated_at ascending" do
      @beretta.touch
      get "/api/v2/weapons", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Colt Python", "Winchester Rifle", "Sword", "Bow", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by updated_at descending" do
      @beretta.touch
      get "/api/v2/weapons", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS", "Bow", "Sword", "Winchester Rifle", "Colt Python"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by name ascending" do
      get "/api/v2/weapons", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS", "Bow", "Colt Python", "Sword", "Winchester Rifle"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by name descending" do
      get "/api/v2/weapons", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Winchester Rifle", "Sword", "Colt Python", "Bow", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by category ascending" do
      get "/api/v2/weapons", params: { sort: "category", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Sword", "Beretta 92FS", "Bow", "Colt Python", "Winchester Rifle"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by category descending" do
      get "/api/v2/weapons", params: { sort: "category", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Winchester Rifle", "Colt Python", "Bow", "Beretta 92FS", "Sword"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by juncture ascending" do
      get "/api/v2/weapons", params: { sort: "juncture", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Bow", "Sword", "Beretta 92FS", "Colt Python", "Winchester Rifle"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "sorts by juncture descending" do
      get "/api/v2/weapons", params: { sort: "juncture", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Winchester Rifle", "Colt Python", "Beretta 92FS", "Sword", "Bow"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "filters by id" do
      get "/api/v2/weapons", params: { id: @beretta.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS"])
      expect(body["categories"]).to eq(["Ranged"])
      expect(body["junctures"]).to eq(["Modern"])
    end
    it "filters by character_id" do
      get "/api/v2/weapons", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS"])
      expect(body["categories"]).to eq(["Ranged"])
      expect(body["junctures"]).to eq(["Modern"])
    end
    it "filters by character_id" do
      get "/api/v2/weapons", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Sword"])
      expect(body["categories"]).to eq(["Melee"])
      expect(body["junctures"]).to eq(["Ancient"])
    end
    it "filters by search string" do
      get "/api/v2/weapons", params: { search: "Beretta" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS"])
      expect(body["categories"]).to eq(["Ranged"])
      expect(body["junctures"]).to eq(["Modern"])
    end
    it "filters by search string" do
      get "/api/v2/weapons", params: { search: "Sword" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Sword"])
      expect(body["categories"]).to eq(["Melee"])
      expect(body["junctures"]).to eq(["Ancient"])
    end
    it "filters by category" do
      get "/api/v2/weapons", params: { category: "Ranged" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Bow", "Winchester Rifle", "Colt Python", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Ranged"])
      expect(body["junctures"]).to eq(["Ancient", "Modern", "Past"])
    end
    it "filters by category" do
      get "/api/v2/weapons", params: { category: "Melee" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Sword"])
      expect(body["categories"]).to eq(["Melee"])
      expect(body["junctures"]).to eq(["Ancient"])
    end
    it "filters category by __NONE__" do
      @longsword = @campaign.weapons.create!(name: "Longsword", description: "A sharp blade.", juncture: "Ancient", category: nil, damage: 8, concealment: nil, reload_value: 0, mook_bonus: 0, kachunk: false)
      get "/api/v2/weapons", params: { category: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Longsword"])
      expect(body["categories"]).to eq([])
      expect(body["junctures"]).to eq(["Ancient"])
    end
    it "filters by juncture" do
      get "/api/v2/weapons", params: { juncture: "Modern" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Colt Python", "Beretta 92FS"])
      expect(body["categories"]).to eq(["Ranged"])
      expect(body["junctures"]).to eq(["Modern"])
    end
    it "filters by juncture" do
      get "/api/v2/weapons", params: { juncture: "Ancient" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Bow", "Sword"])
      expect(body["categories"]).to eq(["Melee", "Ranged"])
      expect(body["junctures"]).to eq(["Ancient"])
    end

    it "filters juncture by __NONE__" do
      @magic_sword = @campaign.weapons.create!(name: "Magic Sword", description: "A mystical blade.", juncture: nil, category: "Melee", damage: 10, concealment: nil, reload_value: 0, mook_bonus: 0, kachunk: false)
      get "/api/v2/weapons", params: { juncture: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Magic Sword"])
      expect(body["categories"]).to eq(["Melee"])
      expect(body["junctures"]).to eq([])
    end
  end

  describe "Pagination and order parameters" do
    it "respects per_page parameter" do
      get "/api/v2/weapons", params: { per_page: 2 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(2)
      expect(body["meta"]["total_count"]).to eq(5)
      expect(body["meta"]["total_pages"]).to eq(3)
    end

    it "respects page parameter" do
      get "/api/v2/weapons", params: { per_page: 2, page: 2 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(2)
      expect(body["meta"]["current_page"]).to eq(2)
    end

    it "sorts by name with order parameter" do
      get "/api/v2/weapons", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Beretta 92FS", "Bow", "Colt Python", "Sword", "Winchester Rifle"])
    end

    it "sorts by name with desc order" do
      get "/api/v2/weapons", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to eq(["Winchester Rifle", "Sword", "Colt Python", "Bow", "Beretta 92FS"])
    end

    it "gets only active weapons by default" do
      get "/api/v2/weapons", headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).not_to include("Hidden Blade")
      expect(body["weapons"].length).to eq(5)
    end

    it "gets only active weapons when show_hidden is false" do
      get "/api/v2/weapons", params: { show_hidden: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).not_to include("Hidden Blade")
      expect(body["weapons"].length).to eq(5)
    end

    it "gets all weapons including hidden when show_hidden is true" do
      get "/api/v2/weapons", params: { show_hidden: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |w| w["name"] }).to include("Hidden Blade")
      expect(body["weapons"].length).to eq(6)
    end
  end

  describe "IDs filtering and caching" do
    it "filters by single id in array" do
      get "/api/v2/weapons", params: { ids: [@beretta.id] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(1)
      expect(body["weapons"][0]["name"]).to eq("Beretta 92FS")
    end

    it "returns empty array when ids contain non-existent ids" do
      get "/api/v2/weapons", params: { ids: ["non-existent-id-1", "non-existent-id-2"] }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq([])
    end

    it "caches results with different ids separately" do
      # First request
      get "/api/v2/weapons", params: { ids: [@beretta.id] }, headers: @headers
      body1 = JSON.parse(response.body)
      
      # Second request with different ids should not return cached result from first
      get "/api/v2/weapons", params: { ids: [@sword.id] }, headers: @headers
      body2 = JSON.parse(response.body)
      
      expect(body1["weapons"][0]["name"]).to eq("Beretta 92FS")
      expect(body2["weapons"][0]["name"]).to eq("Sword")
    end
  end
end
