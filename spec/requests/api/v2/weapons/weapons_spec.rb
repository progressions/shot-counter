require "rails_helper"
RSpec.describe "Api::V2::Weapons", type: :request do
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
    it "creates a new weapon" do
      post "/api/v2/weapons", params: { weapon: { name: "New Weapon", description: "A new weapon", category: "Ranged", juncture: "Modern", damage: 10, concealment: 2, reload_value: 1, mook_bonus: 0, kachunk: false } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Weapon")
      expect(body["category"]).to eq("Ranged")
      expect(body["juncture"]).to eq("Modern")
      expect(body["damage"]).to eq(10)
      expect(body["concealment"]).to eq(2)
      expect(body["reload_value"]).to eq(1)
      expect(body["mook_bonus"]).to eq(0)
      expect(body["kachunk"]).to eq(false)
      expect(body["image_url"]).to be_nil
      expect(Weapon.order("created_at").last.name).to eq("New Weapon")
    end

    it "creates a new weapon with JSON string" do
      post "/api/v2/weapons", params: { weapon: { name: "Json Weapon", description: "A JSON weapon", category: "Melee", juncture: "Ancient", damage: 8, concealment: 0, reload_value: 0, mook_bonus: 0, kachunk: false }.to_json }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Weapon")
      expect(body["category"]).to eq("Melee")
      expect(body["juncture"]).to eq("Ancient")
      expect(body["damage"]).to eq(8)
      expect(body["concealment"]).to eq(0)
      expect(body["reload_value"]).to eq(0)
      expect(body["mook_bonus"]).to eq(0)
      expect(body["kachunk"]).to eq(false)
      expect(Weapon.order("created_at").last.name).to eq("Json Weapon")
    end

    it "returns an error when the weapon name is missing" do
      post "/api/v2/weapons", params: { weapon: { description: "A new weapon", category: "Ranged", juncture: "Modern", damage: 10, concealment: 2, reload_value: 1, mook_bonus: 0, kachunk: false } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "returns an error for invalid JSON string" do
      post "/api/v2/weapons", params: { weapon: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid weapon data format")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/weapons", params: { image: file, weapon: { name: "Weapon with Image", description: "A weapon with image", category: "Ranged", juncture: "Modern", damage: 10, concealment: 2, reload_value: 1, mook_bonus: 0, kachunk: false } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Weapon with Image")
      expect(body["image_url"]).not_to be_nil
      expect(Weapon.order("created_at").last.image.attached?).to be_truthy
    end
  end

  describe "PATCH /update" do
    it "updates an existing weapon" do
      patch "/api/v2/weapons/#{@beretta.id}", params: { weapon: { name: "Updated Beretta", description: "Updated firearm", category: "Ranged", juncture: "Modern", damage: 12, concealment: 1, reload_value: 2, mook_bonus: 1, kachunk: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Beretta")
      expect(body["description"]).to eq("Updated firearm")
      expect(body["category"]).to eq("Ranged")
      expect(body["juncture"]).to eq("Modern")
      expect(body["damage"]).to eq(12)
      expect(body["concealment"]).to eq(1)
      expect(body["reload_value"]).to eq(2)
      expect(body["mook_bonus"]).to eq(1)
      expect(body["kachunk"]).to eq(true)
      @beretta.reload
      expect(@beretta.name).to eq("Updated Beretta")
      expect(@beretta.description).to eq("Updated firearm")
      expect(@beretta.damage).to eq(12)
      expect(@beretta.concealment).to eq(1)
      expect(@beretta.reload_value).to eq(2)
    end

    it "updates an existing weapon with JSON string" do
      patch "/api/v2/weapons/#{@beretta.id}", params: { weapon: { name: "Json Beretta", description: "JSON updated firearm", category: "Ranged", juncture: "Modern", damage: 12, concealment: 1, reload_value: 2, mook_bonus: 1, kachunk: true }.to_json }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Beretta")
      expect(body["description"]).to eq("JSON updated firearm")
      expect(body["category"]).to eq("Ranged")
      expect(body["juncture"]).to eq("Modern")
      expect(body["damage"]).to eq(12)
      expect(body["concealment"]).to eq(1)
      expect(body["reload_value"]).to eq(2)
      expect(body["mook_bonus"]).to eq(1)
      expect(body["kachunk"]).to eq(true)
      @beretta.reload
      expect(@beretta.name).to eq("Json Beretta")
      expect(@beretta.damage).to eq(12)
      expect(@beretta.concealment).to eq(1)
      expect(@beretta.reload_value).to eq(2)
    end

    it "returns an error when the weapon name is missing" do
      patch "/api/v2/weapons/#{@beretta.id}", params: { weapon: { name: "", description: "Updated firearm", category: "Ranged", juncture: "Modern", damage: 12, concealment: 1, reload_value: 2, mook_bonus: 1, kachunk: true } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "name" => ["can't be blank"] })
      @beretta.reload
      expect(@beretta.name).to eq("Beretta 92FS")
      expect(@beretta.damage).to eq(10)
      expect(@beretta.concealment).to eq(2)
      expect(@beretta.reload_value).to eq(1)
    end

    it "returns an error for invalid JSON string" do
      patch "/api/v2/weapons/#{@beretta.id}", params: { weapon: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid weapon data format")
      @beretta.reload
      expect(@beretta.name).to eq("Beretta 92FS")
      expect(@beretta.damage).to eq(10)
      expect(@beretta.concealment).to eq(2)
      expect(@beretta.reload_value).to eq(1)
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/weapons/#{@beretta.id}", params: { image: file, weapon: { name: "Updated Beretta", description: "Updated firearm", category: "Ranged", juncture: "Modern", damage: 12, concealment: 1, reload_value: 2, mook_bonus: 1, kachunk: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Beretta")
      expect(body["image_url"]).not_to be_nil
      @beretta.reload
      expect(@beretta.image.attached?).to be_truthy
      expect(@beretta.damage).to eq(12)
      expect(@beretta.concealment).to eq(1)
      expect(@beretta.reload_value).to eq(2)
    end

    it "replaces an existing image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @beretta.image.attach(file)
      expect(@beretta.image.attached?).to be_truthy
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/weapons/#{@beretta.id}", params: { image: file, weapon: { name: "Updated Beretta", description: "Updated firearm", category: "Ranged", juncture: "Modern", damage: 12, concealment: 1, reload_value: 2, mook_bonus: 1, kachunk: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Beretta")
      expect(body["image_url"]).not_to be_nil
      @beretta.reload
      expect(@beretta.image.attached?).to be_truthy
      expect(@beretta.damage).to eq(12)
      expect(@beretta.concealment).to eq(1)
      expect(@beretta.reload_value).to eq(2)
    end
  end

  describe "GET /show" do
    it "retrieves a weapon" do
      @brick.weapons << @beretta
      get "/api/v2/weapons/#{@beretta.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Beretta 92FS")
      expect(body["description"]).to eq("A powerful firearm.")
      expect(body["category"]).to eq("Ranged")
      expect(body["juncture"]).to eq("Modern")
      expect(body["damage"]).to eq(10)
      expect(body["concealment"]).to eq(2)
      expect(body["reload_value"]).to eq(1)
      expect(body["mook_bonus"]).to eq(0)
      expect(body["kachunk"]).to eq(false)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "description", "category", "juncture", "damage", "concealment", "reload_value", "mook_bonus", "kachunk", "image_url", "created_at", "updated_at")
    end

    it "returns a 404 for a non-existent weapon" do
      get "/api/v2/weapons/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a weapon with no carries" do
      delete "/api/v2/weapons/#{@colt.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Weapon.exists?(@colt.id)).to be_falsey
      expect { @colt.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error for a weapon with carries" do
      delete "/api/v2/weapons/#{@beretta.id}", headers: @headers
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "carries" => true })
      expect(Weapon.exists?(@beretta.id)).to be_truthy
    end

    it "deletes a weapon with carries when force is true" do
      delete "/api/v2/weapons/#{@beretta.id}", params: { force: true }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(Weapon.exists?(@beretta.id)).to be_falsey
      expect { @beretta.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(@brick.reload.weapons).not_to include(@beretta)
    end

    it "returns an error for a non-existent weapon" do
      delete "/api/v2/weapons/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "POST /batch" do
    it "retrieves multiple weapons by IDs" do
      post "/api/v2/weapons/batch", params: { ids: [@sword.id, @beretta.id].join(",") }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].length).to eq(2)
      expect(body["weapons"].map { |w| w["id"] }).to contain_exactly(@sword.id, @beretta.id)
    end

    it "returns empty array when ids is empty" do
      post "/api/v2/weapons/batch", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq([])
    end

    it "returns error when ids parameter is missing" do
      post "/api/v2/weapons/batch", headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("ids parameter is required")
    end
  end

  describe "GET /categories" do
    it "returns weapon categories" do
      get "/api/v2/weapons/categories", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["categories"]).to be_an(Array)
      expect(body["categories"]).to include("Melee", "Ranged")
    end

    it "filters categories by search term" do
      get "/api/v2/weapons/categories", params: { search: "melee" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["categories"]).to include("Melee")
    end
  end

  describe "GET /junctures" do
    it "returns weapon junctures" do
      get "/api/v2/weapons/junctures", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"]).to be_an(Array)
      expect(body["junctures"]).to include("Ancient", "Modern")
    end

    it "filters junctures by search term" do
      get "/api/v2/weapons/junctures", params: { search: "modern" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["junctures"]).to include("Modern")
    end
  end

  describe "DELETE /remove_image" do
    it "removes an image from a weapon" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @beretta.image.attach(image)
      expect(@beretta.image.attached?).to be_truthy
      delete "/api/v2/weapons/#{@beretta.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @beretta.reload
      expect(@beretta.image.attached?).to be_falsey
      expect(@beretta.image_url).to be_nil
    end

    it "returns an error for a non-existent weapon" do
      delete "/api/v2/weapons/999999/image", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end
end
