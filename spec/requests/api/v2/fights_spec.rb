require "rails_helper"

RSpec.describe "Api::V2::Fights", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)

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

  describe "POST /create" do
    it "creates a new fight" do
      post "/api/v2/fights", params: {
        fight: {
          name: "New Fight",
          description: "A new fight description.",
          started_at: Time.now,
          active: true,
        },
      }, headers: @headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Fight")
      expect(body["description"]).to eq("A new fight description.")
      expect(body["active"]).to be true
    end

    it "returns an error when fight data is invalid" do
      post "/api/v2/fights", params: {
        fight: {
          name: "",
          description: "A new fight description.",
          started_at: Time.now,
          active: true,
        },
      }, headers: @headers

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include({ "name" => ["can't be blank"] })
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/fights", params: { image: file, fight: { name: "Fight with Image" } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Fight with Image")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "PATCH /update" do
    it "updates an existing fight" do
      patch "/api/v2/fights/#{@brawl.id}", params: {
        fight: {
          name: "Updated Brawl",
          description: "An updated description for the brawl.",
          active: false,
        },
      }, headers: @headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Brawl")
      expect(body["description"]).to eq("An updated description for the brawl.")
      expect(body["active"]).to be false
    end

    it "returns an error when fight data is invalid" do
      patch "/api/v2/fights/#{@brawl.id}", params: {
        fight: {
          name: "",
          description: "An updated description for the brawl.",
          active: false,
        },
      }, headers: @headers

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include({ "name" => ["can't be blank"] })
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/fights/#{@brawl.id}", params: { image: file, fight: { name: "Updated Brawl" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Brawl")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "GET /show" do
    it "retrieves a fight" do
      get "/api/v2/fights/#{@brawl.id}", headers: @headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Big Brawl")
      expect(body["description"]).to eq("A large fight in the city.")
      expect(body["started_at"]).not_to be_nil
      expect(body["active"]).to be true
      expect(body["image_url"]).to be_nil
    end

    it "retrieves characters in a fight" do
      @brawl.characters << @brick
      @brawl.characters << @serena
      @brawl.characters << @boss

      get "/api/v2/fights/#{@brawl.id}", headers: @headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Big Brawl")
      expect(body["description"]).to eq("A large fight in the city.")
      expect(body["started_at"]).not_to be_nil
      expect(body["active"]).to be true
      expect(body["image_url"]).to be_nil
      expect(body["characters"].map { |c| c["name"] }).to include("Brick Manly", "Serena", "Ugly Shing")
      expect(body["characters"].first.keys).to eq(["id", "name"])
    end

    it "retrieves characters and vehicles in a fight" do
      @brawl.characters << @brick
      @brawl.characters << @serena
      @brawl.characters << @boss

      # create vehicles and add to fight
      vehicle1 = Vehicle.create!(name: "Dragon Flyer", campaign_id: @campaign.id, faction_id: @dragons.id)
      vehicle2 = Vehicle.create!(name: "Ascended Chariot", campaign_id: @campaign.id, faction_id: @ascended.id)
      @brawl.vehicles << vehicle1
      @brawl.vehicles << vehicle2

      get "/api/v2/fights/#{@brawl.id}", headers: @headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Big Brawl")
      expect(body["description"]).to eq("A large fight in the city.")
      expect(body["started_at"]).not_to be_nil
      expect(body["active"]).to be true
      expect(body["image_url"]).to be_nil
      expect(body["characters"].map { |c| c["name"] }).to include("Brick Manly", "Serena", "Ugly Shing")
      expect(body["characters"].first.keys).to eq(["id", "name"])
      expect(body["vehicles"].map { |v| v["name"] }).to include("Dragon Flyer", "Ascended Chariot")
      expect(body["vehicles"].first.keys).to eq(["id", "name"])
    end

    it "returns 404 for a non-existent fight" do
      get "/api/v2/fights/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a fight" do
      delete "/api/v2/fights/#{@brawl.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Fight.exists?(@brawl.id)).to be_falsey
      expect { @brawl.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "PATCH /touch" do
    it "sends a broadcast update" do
      expect_any_instance_of(Fight).to receive(:send).with(:broadcast_update)
      patch "/api/v2/fights/#{@brawl.id}/touch", params: {}, headers: @headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(@brawl.id)
      expect(body["name"]).to eq("Big Brawl")
    end
  end
end
