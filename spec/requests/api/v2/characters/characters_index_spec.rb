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
      description: { "Appearance" => "He's Brick Manly, son" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      juncture_id: @modern.id,
      user_id: @player.id,
    )
    @serena = Character.create!(name: "Serena", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @player.id, juncture_id: @ancient.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id, faction_id: @ascended.id, user_id: @gamemaster.id)
    @featured_foe = Character.create!(name: "Amanda Yin", action_values: { "Type" => "Featured Foe" }, campaign_id: @campaign.id, faction_id: @ascended.id, user_id: @gamemaster.id)
    @mook = Character.create!(name: "Thug", action_values: { "Type" => "Mook" }, campaign_id: @campaign.id, faction_id: @ascended.id, user_id: @gamemaster.id)
    @ally = Character.create!(name: "Angie Lo", action_values: { "Type" => "Ally" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @gamemaster.id)
    @dead_guy = Character.create!(name: "Dead Guy", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @gamemaster.id, active: false)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end
  describe "GET /index" do
    it "gets all characters" do
      get "/api/v2/characters", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "returns character attributes" do
      get "/api/v2/characters", params: { search: "Brick" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].length).to eq(1)
      expect(body["characters"][0]).to include("name" => "Brick Manly")
      expect(body["characters"][0].keys).to include("id", "name", "entity_class")
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "returns an empty array when no characters exist" do
      Character.delete_all
      get "/api/v2/characters", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"]).to eq([])
      expect(body["factions"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 0,
        "total_count" => 0
      })
    end
    it "returns empty array when ids is explicitly empty" do
      get "/api/v2/characters", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"]).to eq([])
      expect(body["factions"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 0,
        "total_count" => 0
      })
    end
    it "filters by comma-separated ids" do
      get "/api/v2/characters", params: { ids: "#{@brick.id},#{@serena.id}" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
      expect(body["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 2
      )
    end
    it "sorts by created_at ascending" do
      get "/api/v2/characters", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by created_at descending" do
      get "/api/v2/characters", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by updated_at ascending" do
      @brick.touch
      get "/api/v2/characters", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by updated_at descending" do
      @brick.touch
      get "/api/v2/characters", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by name ascending" do
      get "/api/v2/characters", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Brick Manly", "Serena", "Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by name descending" do
      get "/api/v2/characters", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Ugly Shing", "Thug", "Serena", "Brick Manly", "Angie Lo", "Amanda Yin"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by type ascending" do
      get "/api/v2/characters", params: { sort: "type", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Ugly Shing", "Amanda Yin", "Thug", "Brick Manly", "Serena"])
      expect(body["characters"].map { |c| c["action_values"]["Type"] }).to eq(["Ally", "Boss", "Featured Foe", "Mook", "PC", "PC"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by type descending" do
      get "/api/v2/characters", params: { sort: "type", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Thug", "Amanda Yin", "Ugly Shing", "Angie Lo"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by archetype ascending" do
      get "/api/v2/characters", params: { sort: "archetype", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Thug", "Ugly Shing", "Brick Manly", "Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "sorts by archetype descending" do
      get "/api/v2/characters", params: { sort: "archetype", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly", "Amanda Yin", "Angie Lo", "Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "filters by faction_id" do
      get "/api/v2/characters", params: { faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by user_id" do
      get "/api/v2/characters", params: { user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "filters by search string" do
      get "/api/v2/characters", params: { search: "Ugly" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end
    it "filters by search string" do
      get "/api/v2/characters", params: { search: "Brick" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by character character_type" do
      get "/api/v2/characters", params: { character_type: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end
    it "filters by character character_type" do
      get "/api/v2/characters", params: { character_type: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by archetype" do
      get "/api/v2/characters", params: { archetype: "Sorcerer" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by archetype" do
      get "/api/v2/characters", params: { archetype: "Everyday Hero" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by party" do
      @dragons_party.characters << @brick
      get "/api/v2/characters", params: { party_id: @dragons_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by party" do
      @ascended_party.characters << @boss
      @ascended_party.characters << @mook
      get "/api/v2/characters", params: { party_id: @ascended_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end
    it "filters by fight" do
      @fight.characters << @brick
      @fight.characters << @serena
      @fight.characters << @boss
      get "/api/v2/characters", params: { sort: "name", order: "asc", fight_id: @fight.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
    it "filters by site" do
      @dragons_hq.characters << @brick
      @dragons_hq.characters << @serena
      get "/api/v2/characters", params: { site_id: @dragons_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by site" do
      @ascended_hq.characters << @boss
      @ascended_hq.characters << @featured_foe
      get "/api/v2/characters", params: { site_id: @ascended_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end
    it "filters by is_template" do
      get "/api/v2/characters", params: { is_template: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Bandit"])
      expect(body["factions"].map { |f| f["name"] }).to eq([])
    end
    it "filters by juncture_id" do
      get "/api/v2/characters", params: { juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end
    it "filters by __NONE__ faction" do
      @no_faction_char = Character.create!(name: "No Faction Character", action_values: { "Type" => "PC" }, campaign_id: @campaign.id, faction_id: nil, user_id: @gamemaster.id)
      get "/api/v2/characters", params: { faction_id: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["No Faction Character"])
      expect(body["factions"].map { |f| f["name"] }).to eq([])
    end
    it "filters by __NONE__ juncture" do
      # First assign junctures to all existing characters
      @boss.update!(juncture: @modern)
      @featured_foe.update!(juncture: @modern)
      @mook.update!(juncture: @modern)  
      @ally.update!(juncture: @modern)
      @no_juncture_char = Character.create!(name: "No Juncture Character", action_values: { "Type" => "PC" }, campaign_id: @campaign.id, juncture_id: nil, user_id: @gamemaster.id)
      get "/api/v2/characters", params: { juncture_id: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["No Juncture Character"])
      expect(body["factions"].map { |f| f["name"] }).to eq([])
    end
    it "filters by __NONE__ archetype" do
      # Most characters have empty archetypes by default, so let's focus on one specific test
      @no_archetype_char = Character.create!(name: "No Archetype Character", action_values: { "Type" => "PC", "Archetype" => "" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
      get "/api/v2/characters", params: { archetype: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to include("No Archetype Character")
      expect(body["characters"].length).to be > 1  # Multiple characters may have empty archetypes
    end
    it "gets only active characters when show_all is false" do
      get "/api/v2/characters", params: { show_all: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |f| f["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["characters"].map { |f| f["name"] }).not_to include("Dead Guy")
    end
    it "gets all characters when show_all is true" do
      get "/api/v2/characters", params: { show_all: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |f| f["name"] }).to eq(["Dead Guy", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
    end
  end
end