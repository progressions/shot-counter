require "rails_helper"

RSpec.describe "Api::V2::Fights", type: :request do
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

    # fights
    @brawl = @campaign.fights.create!(name: "Big Brawl", description: "A large fight in the city.")
    @skirmish = @campaign.fights.create!(name: "Small Skirmish", description: "A minor fight in the alley.")
    @airport_battle = @campaign.fights.create!(name: "Airport Battle", description: "A fight at the airport.")
    @inactive_fight = @campaign.fights.create!(name: "Inactive Fight", description: "This fight is inactive.", active: false)

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
    it "gets all fights" do
      get "/api/v2/fights", headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to include("Big Brawl", "Small Skirmish", "Airport Battle")
    end

    it "filters fights by search term" do
      get "/api/v2/fights", params: { search: "Brawl" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "filters fights by search term" do
      get "/api/v2/fights", params: { search: "Airport" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Airport Battle")
    end

    it "filters fights by id" do
      get "/api/v2/fights", params: { id: @skirmish.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Small Skirmish")
    end

    it "filters fights by id" do
      get "/api/v2/fights", params: { id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "gets only active fights when show_all is false" do
      get "/api/v2/fights", params: { show_all: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to include("Big Brawl", "Small Skirmish", "Airport Battle")
      expect(body["fights"].map { |f| f["name"] }).not_to include("Inactive Fight")
    end

    it "gets all fights when show_all is true" do
      get "/api/v2/fights", params: { show_all: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to include("Big Brawl", "Small Skirmish", "Airport Battle", "Inactive Fight")
    end
  end

end
