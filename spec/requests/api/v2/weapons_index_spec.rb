require "rails_helper"

RSpec.describe "Api::V2::Characters", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
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
    @beretta = @campaign.weapons.create!(name: "Beretta 92FS", description: "A powerful firearm.", juncture: "Modern", category: "Ranged", damage: "10", concealment: "0", reload_value: 1, mook_bonus: 0, kachunk: false)
    @colt = @campaign.weapons.create!(name: "Colt Python", description: "A classic revolver.", juncture: "Modern", category: "Ranged", damage: "12", concealment: "0", reload_value: 1, mook_bonus: 0, kachunk: false)
    @winchest = @campaign.weapons.create!(name: "Winchester Rifle", description: "A reliable rifle.", juncture: "Past", category: "Ranged", damage: "14", concealment: "0", reload_value: 2, mook_bonus: 0, kachunk: false)
    @sword = @campaign.weapons.create!(name: "Sword", description: "A sharp blade.", juncture: "Ancient", category: "Melee", damage: "8", concealment: "0", reload_value: 0, mook_bonus: 0, kachunk: false)
    @bow = @campaign.weapons.create!(name: "Bow", description: "A long-range weapon.", juncture: "Ancient", category: "Ranged", damage: "6", concealment: "0", reload_value: 1, mook_bonus: 0, kachunk: false)

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
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Beretta 92FS"])
    end

    it "returns weapon attributes" do
      get "/api/v2/weapons", params: { search: "Beretta" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(1)
      expect(body["weapons"][0]).to include("name" => "Beretta 92FS", "faction_id" => @dragons.id, "entity_class" => "Character")
      expect(body["weapons"][0].keys).to eq(["id", "name", "image_url", "faction_id", "action_values", "created_at", "updated_at", "description", "entity_class", "skills", "schticks", "image_positions"])
    end

    it "returns an empty array when no weapons exist" do
      Character.delete_all
      get "/api/v2/weapons", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/weapons", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS", "Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/weapons", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Beretta 92FS"])
    end

    it "sorts by updated_at ascending" do
      @brick.touch
      get "/api/v2/weapons", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo", "Beretta 92FS"])
    end

    it "sorts by updated_at descending" do
      @brick.touch
      get "/api/v2/weapons", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena"])
    end

    it "sorts by name ascending" do
      get "/api/v2/weapons", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Beretta 92FS", "Serena", "Thug", "Ugly Shing"])
    end

    it "sorts by name descending" do
      get "/api/v2/weapons", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Ugly Shing", "Thug", "Serena", "Beretta 92FS", "Angie Lo", "Amanda Yin"])
    end

    it "sorts by juncture ascending" do
      get "/api/v2/weapons", params: { sort: "juncture", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Ugly Shing", "Amanda Yin", "Thug", "Beretta 92FS", "Serena"])
      expect(body["weapons"].map { |c| c["action_values"]["Type"] }).to eq(["Ally", "Boss", "Featured Foe", "Mook", "PC", "PC"])
    end

    it "sorts by juncture descending" do
      get "/api/v2/weapons", params: { sort: "juncture", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS", "Serena", "Thug", "Amanda Yin", "Ugly Shing", "Angie Lo"])
      expect(body["weapons"].map { |c| c["action_values"]["Type"] }).to eq(["PC", "PC", "Mook", "Featured Foe", "Boss", "Ally"])
    end

    it "sorts by category ascending" do
      get "/api/v2/weapons", params: { sort: "category", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Thug", "Ugly Shing", "Beretta 92FS", "Serena"])
      expect(body["weapons"].map { |c| c["action_values"]["Archetype"] }).to eq(["", "", "", "", "Everyday Hero", "Sorcerer"])
    end

    it "sorts by category descending" do
      get "/api/v2/weapons", params: { sort: "category", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena", "Beretta 92FS", "Amanda Yin", "Angie Lo", "Thug", "Ugly Shing"])
      expect(body["weapons"].map { |c| c["action_values"]["Archetype"] }).to eq(["Sorcerer", "Everyday Hero", "", "", "", ""])
    end

    it "filters by id" do
      get "/api/v2/weapons", params: { id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS"])
    end

    it "filters by juncture" do
      get "/api/v2/weapons", params: { juncture: "Ancient" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena"])
    end

    it "filters by user_id" do
      get "/api/v2/weapons", params: { user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing"])
    end

    it "filters by search string" do
      get "/api/v2/weapons", params: { search: "Ugly" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Ugly Shing"])
    end

    it "filters by search string" do
      get "/api/v2/weapons", params: { search: "Beretta" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS"])
    end

    it "filters by weapon category" do
      get "/api/v2/weapons", params: { category: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Ugly Shing"])
    end

    it "filters by weapon category" do
      get "/api/v2/weapons", params: { category: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena", "Beretta 92FS"])
    end

    it "filters by juncture" do
      get "/api/v2/weapons", params: { juncture: "Sorcerer" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena"])
    end

    it "filters by juncture" do
      get "/api/v2/weapons", params: { juncture: "Everyday Hero" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS"])
    end
  end

  describe "GET /autocomplete" do
    it "gets all weapons" do
      get "/api/v2/weapons", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Beretta 92FS"])
    end

    it "returns weapon attributes" do
      get "/api/v2/weapons", params: { autocomplete: true, search: "Beretta" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(1)
      expect(body["weapons"][0]).to include("name" => "Beretta 92FS")
      expect(body["weapons"][0].keys).to eq(["id", "name"])
    end

    it "returns an empty array when no weapons exist" do
      Character.delete_all
      get "/api/v2/weapons", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS", "Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Beretta 92FS"])
    end

    it "sorts by updated_at ascending" do
      @brick.touch
      get "/api/v2/weapons", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo", "Beretta 92FS"])
    end

    it "sorts by updated_at descending" do
      @brick.touch
      get "/api/v2/weapons", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena"])
    end

    it "sorts by name ascending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Beretta 92FS", "Serena", "Thug", "Ugly Shing"])
    end

    it "sorts by name descending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Ugly Shing", "Thug", "Serena", "Beretta 92FS", "Angie Lo", "Amanda Yin"])
    end

    it "sorts by category ascending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "category", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Ugly Shing", "Amanda Yin", "Thug", "Beretta 92FS", "Serena"])
      expect(body["weapons"].map { |c| c["action_values"] }.compact).to eq([])
    end

    it "sorts by category descending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "category", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS", "Serena", "Thug", "Amanda Yin", "Ugly Shing", "Angie Lo"])
    end

    it "sorts by juncture ascending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "juncture", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Thug", "Ugly Shing", "Beretta 92FS", "Serena"])
    end

    it "sorts by juncture descending" do
      get "/api/v2/weapons", params: { autocomplete: true, sort: "juncture", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena", "Beretta 92FS", "Amanda Yin", "Angie Lo", "Thug", "Ugly Shing"])
    end

    it "filters by user_id" do
      get "/api/v2/weapons", params: { autocomplete: true, user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing"])
    end

    it "filters by search string" do
      get "/api/v2/weapons", params: { autocomplete: true, search: "Ugly" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Ugly Shing"])
    end

    it "filters by search string" do
      get "/api/v2/weapons", params: { autocomplete: true, search: "Beretta" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS"])
    end

    it "filters by weapon category" do
      get "/api/v2/weapons", params: { autocomplete: true, category: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Ugly Shing"])
    end

    it "filters by weapon category" do
      get "/api/v2/weapons", params: { autocomplete: true, category: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena", "Beretta 92FS"])
    end

    it "filters by juncture" do
      get "/api/v2/weapons", params: { autocomplete: true, juncture: "Sorcerer" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Serena"])
    end

    it "filters by juncture" do
      get "/api/v2/weapons", params: { autocomplete: true, juncture: "Everyday Hero" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |c| c["name"] }).to eq(["Beretta 92FS"])
    end

    it "gets only active weapons when show_all is false" do
      get "/api/v2/weapons", params: { show_all: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |f| f["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Beretta 92FS"])
      expect(body["weapons"].map { |f| f["name"] }).not_to include("Dead Guy")
    end

    it "gets all weapons when show_all is true" do
      get "/api/v2/weapons", params: { show_all: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |f| f["name"] }).to eq(["Dead Guy", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Beretta 92FS"])
    end
  end
end
