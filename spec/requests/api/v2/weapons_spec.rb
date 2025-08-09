require "rails_helper"
RSpec.describe "Api::V2::Weapons", type: :request do
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
    @beretta = @campaign.weapons.create!(name: "Beretta 92FS", description: "A powerful firearm.", juncture: "Modern", category: "Ranged", damage: 10, concealment: 2, reload_value: 1, mook_bonus: 0, kachunk: false)
    @colt = @campaign.weapons.create!(name: "Colt Python", description: "A classic revolver.", juncture: "Modern", category: "Ranged", damage: 12, concealment: 1, reload_value: 1, mook_bonus: 0, kachunk: false)
    @winchest = @campaign.weapons.create!(name: "Winchester Rifle", description: "A reliable rifle.", juncture: "Past", category: "Ranged", damage: 14, concealment: 4, reload_value: 2, mook_bonus: 0, kachunk: false)
    @sword = @campaign.weapons.create!(name: "Sword", description: "A sharp blade.", juncture: "Ancient", category: "Melee", damage: 8, concealment: nil, reload_value: 0, mook_bonus: 0, kachunk: false)
    @bow = @campaign.weapons.create!(name: "Bow", description: "A long-range weapon.", juncture: "Ancient", category: "Ranged", damage: 6, concealment: 3, reload_value: 1, mook_bonus: 0, kachunk: false)
    @brick.weapons << @beretta
    @serena.weapons << @sword
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new character" do
      post "/api/v2/characters", params: { character: { name: "New Character", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Character")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["image_url"]).to be_nil
      expect(Character.order("created_at").last.name).to eq("New Character")
    end

    it "returns an error when the character name is missing" do
      post "/api/v2/characters", params: { character: { action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/characters", params: { image: file, character: { name: "Character with Image", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Character with Image")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "PATCH /update" do
    it "updates an existing character" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { name: "Updated Brick Manly", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" } } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Brick Manly")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      @brick.reload
      expect(@brick.name).to eq("Updated Brick Manly")
      expect(@brick.action_values["Type"]).to eq("PC")
    end

    it "returns an error when the character name is missing" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { name: "", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" } } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "name" => ["can't be blank"]})
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/characters/#{@brick.id}", params: { image: file, character: { name: "Updated Brick Manly", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Brick Manly")
      expect(body["image_url"]).not_to be_nil
    end

    it "updates the juncture" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { juncture: "Ancient" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["juncture"]).to eq("Ancient")
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
      expect(@brick.juncture).to eq("Ancient")
    end
  end

  describe "GET /show" do
    it "retrieves a character" do
      get "/api/v2/characters/#{@brick.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@player.id)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "action_values", "description", "faction_id", "user_id", "image_url", "active", "user", "faction", "juncture", "image_positions", "created_at", "updated_at", "entity_class")
      expect(body["user"]).to eq({ "id" => @player.id, "name" => "Player One", "email" => @player.email })
      expect(body["faction"]).to eq({ "id" => @dragons.id, "name" => "The Dragons" })
      expect(body["juncture"]).to eq({ "id" => @modern.id, "name" => "Modern" })
      expect(body["weapon_ids"].sort).to eq([@sword.id, @gun.id].sort)
    end

    it "returns a 404 for a non-existent character" do
      get "/api/v2/characters/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a character" do
      delete "/api/v2/characters/#{@brick.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Character.exists?(@brick.id)).to be_falsey
      expect { @brick.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE /remove_image" do
    it "removes an image from a character" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @brick.image.attach(image)
      expect(@brick.image.attached?).to be_truthy
      delete "/api/v2/characters/#{@brick.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @brick.reload
      expect(@brick.image.attached?).to be_falsey
      expect(@brick.image_url).to be_nil
    end
  end

end
