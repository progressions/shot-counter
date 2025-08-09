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

    # weapons
    @sword = @campaign.weapons.create!(name: "Sword", description: "A sharp blade.", damage: 10, juncture: "Ancient", category: "Melee")
    @gun = @campaign.weapons.create!(name: "Gun", description: "A ranged weapon.", damage: 15, juncture: "Modern", category: "Ranged")

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

    it "updates the faction" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { faction_id: @ascended.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["faction_id"]).to eq(@ascended.id)
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
      expect(@brick.faction_id).to eq(@ascended.id)
    end
  end

  describe "GET /show" do
    it "retrieves a character" do
      @brick.weapons << @sword
      @brick.weapons << @gun

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

  describe "POST /duplicate" do
    it "duplicates a character" do
      @brick.weapons << @sword
      @brick.weapons << @gun
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Character.count).to eq(9) # 8 original + 1 duplicate
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly (1)")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@gamemaster.id)
      expect(body["image_url"]).to be_nil
      expect(body["weapon_ids"].sort).to eq([@sword.id, @gun.id].sort)
    end

    it "duplicates a character again" do
      @brick.weapons << @sword
      @brick.weapons << @gun
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Character.count).to eq(10)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly (2)")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@gamemaster.id)
      expect(body["image_url"]).to be_nil
      expect(body["weapon_ids"].sort).to eq([@sword.id, @gun.id].sort)
    end

    it "duplicates a character with an image" do
      @brick.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Character.count).to eq(9) # 8 original + 1 duplicate
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly (1)")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "POST /pdf" do
    it "uploads a pdf" do
      file = fixture_file_upload("spec/fixtures/files/Archer.pdf", "application/pdf")
      post "/api/v2/characters/pdf", params: { pdf_file: file }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Archer")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Archer")
      expect(body["action_values"]["MainAttack"]).to eq("Guns")
      expect(body["action_values"]["Guns"]).to eq(14)
      expect(body["action_values"]["Defense"]).to eq(14)
      expect(body["action_values"]["Toughness"]).to eq(6)
      expect(body["action_values"]["Speed"]).to eq(8)
      expect(body["action_values"]["FortuneType"]).to eq("Chi")
      expect(body["action_values"]["Fortune"]).to eq(7)
      expect(body["action_values"]["Max Fortune"]).to eq(7)
    end
  end

end
