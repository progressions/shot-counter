require "rails_helper"
RSpec.describe "Api::V2::Fights", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master", name: "Game Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One", name: "Player One")
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
    @brawl = @campaign.fights.create!(name: "Big Brawl", description: "A large fight in the city.", started_at: 1.hour.ago, season: 1, session: 1)
    @skirmish = @campaign.fights.create!(name: "Small Skirmish", description: "A minor fight in the alley.", season: 2, session: 2)
    @airport_battle = @campaign.fights.create!(name: "Airport Battle", description: "A fight at the airport.", season: 1, session: 3)
    @inactive_fight = @campaign.fights.create!(name: "Inactive Fight", description: "This fight is inactive.", active: false, season: 3, session: 1)
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
    it "gets all active fights" do
      get "/api/v2/fights", headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish", "Big Brawl"])
    end
    it "collects seasons" do
      get "/api/v2/fights", headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["seasons"]).to eq([1, 2])
    end
    it "returns empty array when ids is explicitly empty" do
      get "/api/v2/fights", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"]).to eq([])
      expect(body["seasons"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 0,
        "total_count" => 0
      })
    end
    it "filters by comma-separated ids" do
      get "/api/v2/fights", params: { ids: "#{@brawl.id},#{@skirmish.id}" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish", "Big Brawl"])
      expect(body["seasons"]).to eq([1, 2])
      expect(body["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 2
      )
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
    it "sorts by name ascending" do
      get "/api/v2/fights", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Big Brawl", "Small Skirmish"])
    end
    it "sorts by name descending" do
      get "/api/v2/fights", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish", "Big Brawl", "Airport Battle"])
    end
    it "sorts by created_at ascending" do
      get "/api/v2/fights", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl", "Small Skirmish", "Airport Battle"])
    end
    it "sorts by created_at descending" do
      get "/api/v2/fights", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish", "Big Brawl"])
    end
    it "sorts by updated_at ascending" do
      @skirmish.touch
      get "/api/v2/fights", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl", "Airport Battle", "Small Skirmish"])
    end
    it "sorts by updated_at descending" do
      @skirmish.touch
      get "/api/v2/fights", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish", "Airport Battle", "Big Brawl"])
    end
    it "sorts by season ascending" do
      get "/api/v2/fights", params: { sort: "season", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl", "Airport Battle", "Small Skirmish"])
    end
    it "sorts by season descending" do
      get "/api/v2/fights", params: { sort: "season", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish", "Airport Battle", "Big Brawl"])
    end
    it "sorts by session ascending" do
      get "/api/v2/fights", params: { sort: "session", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl", "Small Skirmish", "Airport Battle"])
    end
    it "sorts by session descending" do
      get "/api/v2/fights", params: { sort: "session", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish", "Big Brawl"])
    end
    it "sorts by started_at ascending" do
      @skirmish.update(started_at: 2.hours.ago)
      @airport_battle.update(started_at: 1.hour.ago)
      get "/api/v2/fights", params: { sort: "started_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish", "Big Brawl", "Airport Battle"])
    end
    it "sorts by started_at descending" do
      @skirmish.update(started_at: 2.hours.ago)
      @airport_battle.update(started_at: 1.hour.ago)
      get "/api/v2/fights", params: { sort: "started_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Big Brawl", "Small Skirmish"])
    end
    it "sorts by ended_at ascending" do
      @brawl.update(ended_at: 2.hours.ago)
      @skirmish.update(ended_at: 1.hour.ago)
      get "/api/v2/fights", params: { sort: "ended_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl", "Small Skirmish", "Airport Battle"])
    end
    it "sorts by ended_at descending" do
      @brawl.update(ended_at: 2.hours.ago)
      @skirmish.update(ended_at: 1.hour.ago)
      get "/api/v2/fights", params: { sort: "ended_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish", "Big Brawl"])
    end
    it "filters by season" do
      get "/api/v2/fights", params: { season: 1 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Big Brawl"])
    end
    it "filters by session" do
      get "/api/v2/fights", params: { session: 2 }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish"])
    end
    it "filters by __NONE__ season" do
      @no_season_fight = @campaign.fights.create!(name: "No Season Fight", description: "A fight without season.", season: nil, session: 1)
      get "/api/v2/fights", params: { season: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["No Season Fight"])
    end
    it "filters by __NONE__ session" do
      @no_session_fight = @campaign.fights.create!(name: "No Session Fight", description: "A fight without session.", season: 1, session: nil)
      get "/api/v2/fights", params: { session: "__NONE__" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["No Session Fight"])
    end
    it "gets only active fights when show_hidden is false" do
      get "/api/v2/fights", params: { show_hidden: false }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish", "Big Brawl"])
      expect(body["fights"].map { |f| f["name"] }).not_to include("Inactive Fight")
    end
    it "gets all fights when show_hidden is true" do
      get "/api/v2/fights", params: { show_hidden: true }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Inactive Fight", "Airport Battle", "Small Skirmish", "Big Brawl"])
    end
    it "filters unstarted fights" do
      @brawl.update(started_at: Time.now)
      get "/api/v2/fights", params: { status: "Unstarted" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Airport Battle", "Small Skirmish"])
      expect(body["fights"].map { |f| f["name"] }).not_to include("Big Brawl")
    end
    it "filters unended fights" do
      @brawl.update(started_at: 1.hour.ago)
      get "/api/v2/fights", params: { status: "Started" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Big Brawl"])
    end
    it "filters ended fights" do
      @brawl.update(started_at: 2.hours.ago, ended_at: 1.hour.ago)
      @skirmish.update(started_at: 2.hours.ago, ended_at: 1.hour.ago)
      get "/api/v2/fights", params: { status: "Ended" }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].map { |f| f["name"] }).to eq(["Small Skirmish", "Big Brawl"])
      expect(body["fights"].map { |f| f["name"] }).not_to include("Airport Battle")
    end
    it "filters by character involvement" do
      shot = Shot.create!(fight: @brawl, character: @brick)
      @brawl.shots << shot
      @brawl.save!
      get "/api/v2/fights", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end
    it "filters by character involvement" do
      shot = Shot.create!(fight: @skirmish, character: @serena)
      @skirmish.shots << shot
      @skirmish.save!
      get "/api/v2/fights", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Small Skirmish")
    end
    it "filters by vehicle involvement" do
      vehicle = @campaign.vehicles.create!(name: "Speedster", campaign_id: @campaign.id, user_id: @player.id)
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
      shot = Shot.create!(fight: @brawl, character: @brick)
      @brawl.shots << shot
      @brawl.save!
      get "/api/v2/fights", params: { user_id: @player.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["fights"].length).to eq(1)
      expect(body["fights"].first["name"]).to eq("Big Brawl")
    end
    it "returns distinct fights when user has multiple characters in the same fight" do
      shot1 = Shot.create!(fight: @brawl, character: @boss)
      shot2 = Shot.create!(fight: @brawl, character: @featured_foe)
      shot3 = Shot.create!(fight: @brawl, character: @mook)
      @brawl.shots << [shot1, shot2, shot3]
      @brawl.save!
      get "/api/v2/fights", params: { user_id: @gamemaster.id }, headers: @headers
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
      expect(fight["season"]).to eq(1)
      expect(fight["session"]).to eq(1)
      expect(fight["active"]).to be true
      expect(fight.keys).to include("id", "name", "description", "campaign_id", "started_at", "ended_at", "created_at", "updated_at", "active", "season", "session", "entity_class", "image_positions")
    end
    it "returns characters in fight" do
      shot1 = Shot.create!(fight: @brawl, character: @brick)
      shot2 = Shot.create!(fight: @brawl, character: @serena)
      @brawl.shots << [shot1, shot2]
      @brawl.save!
      get "/api/v2/fights", params: { id: @brawl.id }, headers: @headers
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      fight = body["fights"].first
      character_names = fight["characters"].map { |c| c["name"] }
      expect(character_names).to include("Brick Manly", "Serena")
    end
    it "returns vehicles in fight" do
      vehicle = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, user_id: @player.id)
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
end
