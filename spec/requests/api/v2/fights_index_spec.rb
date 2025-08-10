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
    @brawl = @campaign.fights.create!(name: "Big Brawl", description: "A large fight in the city.", started_at: 1.hour.ago)
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

    it "filters unstarted fights" do
      @brawl.update(started_at: Time.now)
      get "/api/v2/fights", params: { unstarted: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish"])
      expect(body["fights"].map { |f| f["name"] }).not_to include("Big Brawl")
    end

    it "filters unended fights" do
      @brawl.update(started_at: 1.hour.ago)
      get "/api/v2/fights", params: { unended: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl"])
    end

    it "filters by character involvement" do
      # Add Brick to Big Brawl
      @brawl.characters << @brick
      @brawl.save!

      get "/api/v2/fights", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "filters by character involvement" do
      # Add Serena to Small Skirmish
      @skirmish.characters << @serena
      @skirmish.save!

      get "/api/v2/fights", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Small Skirmish")
    end

    it "filters by vehicle involvement" do
      # Create vehicle and add to Airport Battle
      vehicle = Vehicle.create!(name: "Speedster", campaign_id: @campaign.id, user_id: @player.id)
      shot = Shot.create!(fight: @airport_battle, vehicle: vehicle)
      @airport_battle.shots << shot
      @airport_battle.save!

      get "/api/v2/fights", params: { vehicle_id: vehicle.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Airport Battle")
    end

    it "filters by player involvement" do
      # Add Brick (player's character) to Big Brawl
      @brawl.characters << @brick
      @brawl.save!
      get "/api/v2/fights", params: { user_id: @player.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "returns fight attributes" do
      get "/api/v2/fights", params: { id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      expect(fight["name"]).to eq("Big Brawl")
      expect(fight["description"]).to eq("A large fight in the city.")
      expect(fight["started_at"]).not_to be_nil
      expect(fight["ended_at"]).to be_nil
      expect(fight["active"]).to be true
    end

    it "returns characters in fight" do
      # Add Brick and Serena to Big Brawl
      @brawl.characters << @brick
      @brawl.characters << @serena
      @brawl.save!

      get "/api/v2/fights", params: { id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      character_names = fight["characters"].map { |c| c["name"] }
      expect(character_names).to include("Brick Manly", "Serena")
    end

    it "returns vehicles in fight" do
      # Create vehicle and add to Big Brawl
      vehicle = Vehicle.create!(name: "Tank", campaign_id: @campaign.id, user_id: @player.id)
      shot = Shot.create!(fight: @brawl, vehicle: vehicle)
      @brawl.shots << shot
      @brawl.save!

      get "/api/v2/fights", params: { id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      vehicle_names = fight["vehicles"].map { |v| v["name"] }
      expect(vehicle_names).to include("Tank")
    end
  end

  describe "GET /fights?autocomplete=true" do
    it "gets all fights" do
      get "/api/v2/fights", params: { autocomplete: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to include("Big Brawl", "Small Skirmish", "Airport Battle")
    end

    it "filters fights by search term" do
      get "/api/v2/fights", params: { autocomplete: true, search: "Brawl" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "filters fights by search term" do
      get "/api/v2/fights", params: { autocomplete: true, search: "Airport" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Airport Battle")
    end

    it "filters fights by id" do
      get "/api/v2/fights", params: { autocomplete: true, id: @skirmish.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Small Skirmish")
    end

    it "filters fights by id" do
      get "/api/v2/fights", params: { autocomplete: true, id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "gets only active fights when show_all is false" do
      get "/api/v2/fights", params: { autocomplete: true, show_all: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to include("Big Brawl", "Small Skirmish", "Airport Battle")
      expect(body["fights"].map { |f| f["name"] }).not_to include("Inactive Fight")
    end

    it "gets all fights when show_all is true" do
      get "/api/v2/fights", params: { autocomplete: true, show_all: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to include("Big Brawl", "Small Skirmish", "Airport Battle", "Inactive Fight")
    end

    it "filters unstarted fights" do
      @brawl.update(started_at: Time.now)
      get "/api/v2/fights", params: { autocomplete: true, unstarted: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish"])
      expect(body["fights"].map { |f| f["name"] }).not_to include("Big Brawl")
    end

    it "filters unended fights" do
      @brawl.update(started_at: 1.hour.ago)
      get "/api/v2/fights", params: { autocomplete: true, unended: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl"])
    end

    it "filters by character involvement" do
      # Add Brick to Big Brawl
      @brawl.characters << @brick
      @brawl.save!

      get "/api/v2/fights", params: { autocomplete: true, character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "filters by character involvement" do
      # Add Serena to Small Skirmish
      @skirmish.characters << @serena
      @skirmish.save!

      get "/api/v2/fights", params: { autocomplete: true, character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Small Skirmish")
    end

    it "filters by vehicle involvement" do
      # Create vehicle and add to Airport Battle
      vehicle = Vehicle.create!(name: "Speedster", campaign_id: @campaign.id, user_id: @player.id)
      shot = Shot.create!(fight: @airport_battle, vehicle: vehicle)
      @airport_battle.shots << shot
      @airport_battle.save!

      get "/api/v2/fights", params: { autocomplete: true, vehicle_id: vehicle.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Airport Battle")
    end

    it "filters by player involvement" do
      # Add Brick (player's character) to Big Brawl
      @brawl.characters << @brick
      @brawl.save!
      get "/api/v2/fights", params: { autocomplete: true, user_id: @player.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end

    it "returns fight attributes" do
      get "/api/v2/fights", params: { autocomplete: true, id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      expect(fight["name"]).to eq("Big Brawl")
      expect(fight["description"]).to be_nil
      expect(fight["started_at"]).to be_nil
      expect(fight["ended_at"]).to be_nil
      expect(fight["active"]).to be_nil
    end

    it "doesn't return characters in fight" do
      # Add Brick and Serena to Big Brawl
      @brawl.characters << @brick
      @brawl.characters << @serena
      @brawl.save!

      get "/api/v2/fights", params: { autocomplete: true, id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      expect(fight["characters"]).not_to be_present
    end

    it "returns vehicles in fight" do
      # Create vehicle and add to Big Brawl
      vehicle = Vehicle.create!(name: "Tank", campaign_id: @campaign.id, user_id: @player.id)
      shot = Shot.create!(fight: @brawl, vehicle: vehicle)
      @brawl.shots << shot
      @brawl.save!

      get "/api/v2/fights", params: { autocomplete: true, id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      expect(fight["vehicles"]).not_to be_present
    end
  end

end
