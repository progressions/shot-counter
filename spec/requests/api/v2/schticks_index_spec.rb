require "rails_helper"

RSpec.describe "Api::V2::Characters", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")

    @campaign = @gamemaster.campaigns.create!(name: "Adventure")

    # characters
    @bandit = Character.create!(name: "Bandit", action_values: { "Type" => "PC", "Archetype" => "Bandit" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Martial Arts" => 13, "MainAttack" => "Martial Arts" },
      description: { "Appearance" => "He's Brick Manly, son" },
      campaign_id: @campaign.id,
      user_id: @player.id,
    )
    @serena = Character.create!(name: "Serena", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, user_id: @player.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @featured_foe = Character.create!(name: "Amanda Yin", action_values: { "Type" => "Featured Foe" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @mook = Character.create!(name: "Thug", action_values: { "Type" => "Mook" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @ally = Character.create!(name: "Angie Lo", action_values: { "Type" => "Ally" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @dead_guy = Character.create!(name: "Dead Guy", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" }, campaign_id: @campaign.id, user_id: @gamemaster.id, active: false)

    # schticks
    @fireball = Schtick.create!(name: "Fireball", description: "Throws a fireball", category: "Sorcery", path: "Fire", campaign_id: @campaign.id)
    @blast = Schtick.create!(name: "Blast", description: "A big blast", category: "Sorcery", path: "Force", campaign_id: @campaign.id)
    @punch = Schtick.create!(name: "Punch", description: "Throws a punch", category: "Martial Arts", path: "Path of the Tiger", campaign_id: @campaign.id)
    @kick = Schtick.create!(name: "Kick", description: "A flying kick", category: "Martial Arts", path: "Path of the Tiger", campaign_id: @campaign.id)
    @serena.schticks << @fireball
    @serena.schticks << @blast
    @brick.schticks << @punch
    @brick.schticks << @kick

    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    it "gets all schticks" do
      get "/api/v2/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Fireball", "Blast", "Punch", "Kick"])
    end

    it "returns schtick attributes" do
      get "/api/v2/schticks", params: { search: "Fireball" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].length).to eq(1)
      expect(body["schticks"][0]).to include("name" => "Fireball", "entity_class" => "Schtick")
      expect(body["schticks"][0].keys).to eq(["id", "name", "image_url", "description", "category", "path", "created_at", "updated_at", "entity_class", "prerequisite_id", "image_positions"])
    end

    it "returns an empty array when no schticks exist" do
      CharacterSchtick.delete_all
      Schtick.delete_all
      get "/api/v2/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq([])
      expect(body["factions"]).to eq([])
    end

=begin
    it "sorts by created_at ascending" do
      get "/api/v2/schticks", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/schticks", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @brick.touch
      get "/api/v2/schticks", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @brick.touch
      get "/api/v2/schticks", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/schticks", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Brick Manly", "Serena", "Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/schticks", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Ugly Shing", "Thug", "Serena", "Brick Manly", "Angie Lo", "Amanda Yin"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type ascending" do
      get "/api/v2/schticks", params: { sort: "type", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Ugly Shing", "Amanda Yin", "Thug", "Brick Manly", "Serena"])
      expect(body["schticks"].map { |c| c["action_values"]["Type"] }).to eq(["Ally", "Boss", "Featured Foe", "Mook", "PC", "PC"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type descending" do
      get "/api/v2/schticks", params: { sort: "type", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Thug", "Amanda Yin", "Ugly Shing", "Angie Lo"])
      expect(body["schticks"].map { |c| c["action_values"]["Type"] }).to eq(["PC", "PC", "Mook", "Featured Foe", "Boss", "Ally"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype ascending" do
      get "/api/v2/schticks", params: { sort: "archetype", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Thug", "Ugly Shing", "Brick Manly", "Serena"])
      expect(body["schticks"].map { |c| c["action_values"]["Archetype"] }).to eq(["", "", "", "", "Everyday Hero", "Sorcerer"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype descending" do
      get "/api/v2/schticks", params: { sort: "archetype", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly", "Amanda Yin", "Angie Lo", "Thug", "Ugly Shing"])
      expect(body["schticks"].map { |c| c["action_values"]["Archetype"] }).to eq(["Sorcerer", "Everyday Hero", "", "", "", ""])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by id" do
      get "/api/v2/schticks", params: { id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/schticks", params: { faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/schticks", params: { faction_id: @ascended.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Thug", "Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by juncture_id" do
      get "/api/v2/schticks", params: { juncture_id: @modern.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by juncture_id" do
      get "/api/v2/schticks", params: { juncture_id: @ancient.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by user_id" do
      get "/api/v2/schticks", params: { user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/schticks", params: { search: "Ugly" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/schticks", params: { search: "Brick" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by schtick type" do
      get "/api/v2/schticks", params: { type: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by schtick type" do
      get "/api/v2/schticks", params: { type: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by archetype" do
      get "/api/v2/schticks", params: { archetype: "Sorcerer" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by archetype" do
      get "/api/v2/schticks", params: { archetype: "Everyday Hero" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @dragons_party.schticks << @brick
      get "/api/v2/schticks", params: { party_id: @dragons_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @ascended_party.schticks << @boss
      @ascended_party.schticks << @mook
      get "/api/v2/schticks", params: { party_id: @ascended_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by fight" do
      @fight.schticks << @brick
      @fight.schticks << @serena
      @fight.schticks << @boss
      get "/api/v2/schticks", params: { sort: "name", order: "asc", fight_id: @fight.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by site" do
      @dragons_hq.schticks << @brick
      @dragons_hq.schticks << @serena
      get "/api/v2/schticks", params: { site_id: @dragons_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by site" do
      @ascended_hq.schticks << @boss
      @ascended_hq.schticks << @featured_foe
      get "/api/v2/schticks", params: { site_id: @ascended_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by is_template" do
      get "/api/v2/schticks", params: { is_template: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Bandit"])
      expect(body["factions"].map { |f| f["name"] }).to eq([])
    end
  end

  describe "GET /autocomplete" do
    it "gets all schticks" do
      get "/api/v2/schticks", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "returns schtick attributes" do
      get "/api/v2/schticks", params: { autocomplete: true, search: "Brick" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].length).to eq(1)
      expect(body["schticks"][0]).to include("name" => "Brick Manly")
      expect(body["schticks"][0].keys).to eq(["id", "name"])
    end

    it "returns an empty array when no schticks exist" do
      Schtick.delete_all
      get "/api/v2/schticks", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq([])
      expect(body["factions"]).to eq([])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at ascending" do
      @brick.touch
      get "/api/v2/schticks", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Ugly Shing", "Amanda Yin", "Thug", "Angie Lo", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by updated_at descending" do
      @brick.touch
      get "/api/v2/schticks", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name ascending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Brick Manly", "Serena", "Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by name descending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Ugly Shing", "Thug", "Serena", "Brick Manly", "Angie Lo", "Amanda Yin"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type ascending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "type", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Ugly Shing", "Amanda Yin", "Thug", "Brick Manly", "Serena"])
      expect(body["schticks"].map { |c| c["action_values"] }.compact).to eq([])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by type descending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "type", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Thug", "Amanda Yin", "Ugly Shing", "Angie Lo"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype ascending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "archetype", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Amanda Yin", "Angie Lo", "Thug", "Ugly Shing", "Brick Manly", "Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "sorts by archetype descending" do
      get "/api/v2/schticks", params: { autocomplete: true, sort: "archetype", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly", "Amanda Yin", "Angie Lo", "Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by faction_id" do
      get "/api/v2/schticks", params: { autocomplete: true, faction_id: @dragons.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by user_id" do
      get "/api/v2/schticks", params: { autocomplete: true, user_id: @gamemaster.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by search string" do
      get "/api/v2/schticks", params: { autocomplete: true, search: "Ugly" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by search string" do
      get "/api/v2/schticks", params: { autocomplete: true, search: "Brick" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by schtick type" do
      get "/api/v2/schticks", params: { autocomplete: true, type: "Boss" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by schtick type" do
      get "/api/v2/schticks", params: { autocomplete: true, type: "PC" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by archetype" do
      get "/api/v2/schticks", params: { autocomplete: true, archetype: "Sorcerer" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by archetype" do
      get "/api/v2/schticks", params: { autocomplete: true, archetype: "Everyday Hero" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @dragons_party.schticks << @brick
      get "/api/v2/schticks", params: { autocomplete: true, party_id: @dragons_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by party" do
      @ascended_party.schticks << @boss
      @ascended_party.schticks << @mook
      get "/api/v2/schticks", params: { autocomplete: true, party_id: @ascended_party.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Thug", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by fight" do
      @fight.schticks << @brick
      @fight.schticks << @serena
      @fight.schticks << @boss
      get "/api/v2/schticks", params: { autocomplete: true, sort: "name", order: "asc", fight_id: @fight.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Brick Manly", "Serena", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    it "filters by site" do
      @dragons_hq.schticks << @brick
      @dragons_hq.schticks << @serena
      get "/api/v2/schticks", params: { autocomplete: true, site_id: @dragons_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Serena", "Brick Manly"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
    end

    it "filters by site" do
      @ascended_hq.schticks << @boss
      @ascended_hq.schticks << @featured_foe
      get "/api/v2/schticks", params: { autocomplete: true, site_id: @ascended_hq.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Amanda Yin", "Ugly Shing"])
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
    end

    it "filters by is_template" do
      get "/api/v2/schticks", params: { autocomplete: true, is_template: true }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Bandit"])
      expect(body["factions"].map { |f| f["name"] }).to eq([])
    end

    it "gets only active schticks when show_all is false" do
      get "/api/v2/schticks", params: { show_all: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |f| f["name"] }).to eq(["Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
      expect(body["schticks"].map { |f| f["name"] }).not_to include("Dead Guy")
    end

    it "gets all schticks when show_all is true" do
      get "/api/v2/schticks", params: { show_all: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |f| f["name"] }).to eq(["Dead Guy", "Angie Lo", "Thug", "Amanda Yin", "Ugly Shing", "Serena", "Brick Manly"])
    end
=end
  end
end

