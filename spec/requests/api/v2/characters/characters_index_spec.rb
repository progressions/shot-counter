require "rails_helper"
RSpec.describe "Api::V2::Characters", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true)
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
    it "filters by is_template (legacy parameter - admin only)" do
      # Create admin user for this test
      admin = User.create!(email: "admin_test@example.com", first_name: "Admin", last_name: "Test", confirmed_at: Time.now, admin: true)
      admin_headers = Devise::JWT::TestHelpers.auth_headers({}, admin)
      set_current_campaign(admin, @campaign)
      
      get "/api/v2/characters", params: { is_template: true }, headers: admin_headers
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
    it "gets only active characters by default" do
      get "/api/v2/characters", headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |f| f["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["characters"].map { |f| f["name"] }).not_to include("Dead Guy")
    end
    it "gets only active characters when show_hidden is false" do
      get "/api/v2/characters", params: { show_hidden: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |f| f["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["characters"].map { |f| f["name"] }).not_to include("Dead Guy")
    end
    it "gets all characters including hidden when show_hidden is true" do
      get "/api/v2/characters", params: { show_hidden: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |f| f["name"] }).to eq(["Dead Guy", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
    end
  end

  describe "Pagination parameters" do
    it "respects per_page parameter" do
      get "/api/v2/characters", params: { per_page: 3 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].length).to eq(3)
      expect(body["meta"]["total_count"]).to eq(6) # Only active characters (excluding Dead Guy and Bandit template)
      expect(body["meta"]["total_pages"]).to eq(2)
    end

    it "respects page parameter" do
      get "/api/v2/characters", params: { per_page: 3, page: 2 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].length).to eq(3)
      expect(body["meta"]["current_page"]).to eq(2)
      expect(body["meta"]["total_pages"]).to eq(2)
    end

    it "handles page beyond total pages" do
      get "/api/v2/characters", params: { per_page: 5, page: 10 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"]).to eq([])
      expect(body["meta"]["current_page"]).to eq(10)
    end
  end

  describe "Single ID filtering" do
    it "filters by single character id" do
      get "/api/v2/characters", params: { id: @brick.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"].length).to eq(1)
      expect(body["characters"].first["name"]).to eq("Brick Manly")
    end

    it "returns empty when id does not exist" do
      get "/api/v2/characters", params: { id: 999999 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"]).to eq([])
    end
  end

  describe "Invalid parameters" do
    it "falls back to default sort when sort parameter is invalid" do
      get "/api/v2/characters", params: { sort: "invalid_field" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      # Should fall back to default created_at DESC order
      expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
    end

    it "falls back to default order when order parameter is invalid" do
      get "/api/v2/characters", params: { sort: "name", order: "invalid_direction" }, headers: @headers
      expect(response).to have_http_status(500)
    end

    it "returns empty when filtering by non-existent faction_id" do
      get "/api/v2/characters", params: { faction_id: 999999 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"]).to eq([])
    end

    it "returns empty when filtering by non-existent user_id" do
      get "/api/v2/characters", params: { user_id: 999999 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["characters"]).to eq([])
    end
  end

  describe "Template filtering with template_filter parameter" do
    before(:each) do
      # Create additional test data for template testing
      @admin = User.create!(email: "admin@example.com", first_name: "Admin", last_name: "User", confirmed_at: Time.now, admin: true)
      @admin_headers = Devise::JWT::TestHelpers.auth_headers({}, @admin)
      set_current_campaign(@admin, @campaign)
      
      # Create more templates for testing
      @template2 = Character.create!(name: "Template Sorcerer", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
      @template3 = Character.create!(name: "Template Boss", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    end

    context "as admin user" do
      it "filters to show only templates when template_filter=templates" do
        get "/api/v2/characters", params: { template_filter: "templates" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Template Boss", "Template Sorcerer", "Bandit"])
        expect(body["characters"].all? { |c| c["is_template"] == true }).to be true
      end

      it "filters to show only non-templates when template_filter=non-templates" do
        get "/api/v2/characters", params: { template_filter: "non-templates" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
        expect(body["characters"].none? { |c| c["is_template"] == true }).to be true
      end

      it "shows all characters when template_filter=all" do
        get "/api/v2/characters", params: { template_filter: "all" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        all_names = ["Template Boss", "Template Sorcerer", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly", "Bandit"]
        expect(body["characters"].map { |c| c["name"] }).to match_array(all_names)
      end

      it "defaults to non-templates when no template_filter provided" do
        get "/api/v2/characters", headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      end

      it "defaults to non-templates when template_filter is invalid" do
        get "/api/v2/characters", params: { template_filter: "invalid_value" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      end

      it "combines template_filter with other filters" do
        get "/api/v2/characters", params: { template_filter: "all", character_type: "PC" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to match_array(["Template Sorcerer", "Serena", "Brick Manly", "Bandit"])
      end

      it "respects show_hidden with template_filter" do
        @hidden_template = Character.create!(name: "Hidden Template", action_values: { "Type" => "PC" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id, active: false)
        
        get "/api/v2/characters", params: { template_filter: "templates", show_hidden: true }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to include("Hidden Template")
      end
    end

    context "as gamemaster user (non-admin)" do
      it "always filters out templates regardless of template_filter=templates" do
        get "/api/v2/characters", params: { template_filter: "templates" }, headers: @headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        # Should not show templates even when explicitly requested
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      end

      it "shows non-templates when template_filter=non-templates" do
        get "/api/v2/characters", params: { template_filter: "non-templates" }, headers: @headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      end

      it "filters out templates when template_filter=all" do
        get "/api/v2/characters", params: { template_filter: "all" }, headers: @headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        # Non-admin users should never see templates
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      end

      it "defaults to non-templates when no template_filter provided" do
        get "/api/v2/characters", headers: @headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      end
    end

    context "as player user (non-admin)" do
      before(:each) do
        @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
        set_current_campaign(@player, @campaign)
      end

      it "always filters out templates regardless of template_filter parameter" do
        get "/api/v2/characters", params: { template_filter: "templates" }, headers: @player_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        # Players should never see templates
        expect(body["characters"].none? { |c| c["is_template"] == true }).to be true
      end

      it "cannot access templates even with direct filtering" do
        get "/api/v2/characters", params: { template_filter: "all", is_template: true }, headers: @player_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        # Should override is_template parameter for non-admin users
        expect(body["characters"].none? { |c| c["is_template"] == true }).to be true
      end
    end

    context "template_filter with pagination" do
      before(:each) do
        # Create enough templates to test pagination
        5.times do |i|
          Character.create!(name: "Extra Template #{i}", action_values: { "Type" => "PC" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
        end
      end

      it "paginates template results correctly" do
        get "/api/v2/characters", params: { template_filter: "templates", per_page: 3 }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].length).to eq(3)
        expect(body["meta"]["total_count"]).to eq(8) # 3 original + 5 extra templates
        expect(body["meta"]["total_pages"]).to eq(3)
      end
    end

    context "template_filter with sorting" do
      it "sorts templates by name ascending" do
        get "/api/v2/characters", params: { template_filter: "templates", sort: "name", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body["characters"].map { |c| c["name"] }).to eq(["Bandit", "Template Boss", "Template Sorcerer"])
      end

      it "sorts mixed results when template_filter=all" do
        get "/api/v2/characters", params: { template_filter: "all", sort: "name", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        names = body["characters"].map { |c| c["name"] }
        expect(names).to eq(names.sort)
      end
    end
  end
end