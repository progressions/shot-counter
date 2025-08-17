require "rails_helper"
RSpec.describe "Api::V2::Junctures", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.", faction_id: @dragons.id, active: true)
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.", faction_id: @ascended.id, active: true)
    @future = @campaign.junctures.create!(name: "Future", description: "A futuristic era.", faction_id: @dragons.id, active: true)
    @inactive_juncture = @campaign.junctures.create!(name: "Inactive Juncture", description: "A retired era.", faction_id: @ascended.id, active: false)
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
    @serena = Character.create!(
      name: "Serena",
      action_values: { "Type" => "PC", "Archetype" => "Sorcerer" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      juncture_id: @ancient.id,
      user_id: @player.id,
    )
    # vehicles
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id, juncture_id: @modern.id)
    @jet = @campaign.vehicles.create!(name: "Jet", campaign_id: @campaign.id, faction_id: @ascended.id, juncture_id: @ancient.id)
    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id, juncture_id: @ancient.id)
    # sites
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", faction_id: @ascended.id, juncture_id: @ancient.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new juncture" do
      post "/api/v2/junctures", params: { juncture: { name: "New Juncture", description: "A new era", faction_id: @dragons.id, active: true, character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Juncture")
      expect(body["description"]).to eq("A new era")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["active"]).to eq(true)
      expect(body["character_ids"]).to include(@brick.id)
      expect(body["image_url"]).to be_nil
      expect(Juncture.order("created_at").last.name).to eq("New Juncture")
    end

    it "creates a new juncture with JSON string" do
      post "/api/v2/junctures", params: { juncture: { name: "Json Juncture", description: "A JSON era", faction_id: @ascended.id, active: true, character_ids: [@serena.id] }.to_json }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Juncture")
      expect(body["description"]).to eq("A JSON era")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(true)
      expect(body["character_ids"]).to include(@serena.id)
      expect(Juncture.order("created_at").last.name).to eq("Json Juncture")
    end

    it "returns an error when the juncture name is missing" do
      post "/api/v2/junctures", params: { juncture: { description: "A new era", faction_id: @dragons.id, active: true, character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "returns an error for invalid JSON string" do
      post "/api/v2/junctures", params: { juncture: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid juncture data format")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/junctures", params: { image: file, juncture: { name: "Juncture with Image", description: "A juncture with image", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Juncture with Image")
      expect(body["image_url"]).not_to be_nil
      expect(Juncture.order("created_at").last.image.attached?).to be_truthy
    end
  end

  describe "PATCH /update" do
    it "updates an existing juncture" do
      patch "/api/v2/junctures/#{@modern.id}", params: { juncture: { name: "Updated Modern", description: "Updated modern world", faction_id: @ascended.id, active: false, character_ids: [@serena.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Modern")
      expect(body["description"]).to eq("Updated modern world")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(false)
      expect(body["character_ids"]).to include(@serena.id)
      @modern.reload
      expect(@modern.name).to eq("Updated Modern")
      expect(@modern.description).to eq("Updated modern world")
      expect(@modern.faction_id).to eq(@ascended.id)
      expect(@modern.characters).to include(@serena)
    end

    it "updates an existing juncture with JSON string" do
      patch "/api/v2/junctures/#{@modern.id}", params: { juncture: { name: "Json Modern", description: "JSON updated modern world", faction_id: @ascended.id, active: false, character_ids: [@serena.id] }.to_json }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Modern")
      expect(body["description"]).to eq("JSON updated modern world")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(false)
      expect(body["character_ids"]).to include(@serena.id)
      @modern.reload
      expect(@modern.name).to eq("Json Modern")
      expect(@modern.characters).to include(@serena)
    end

    it "returns an error when the juncture name is missing" do
      patch "/api/v2/junctures/#{@modern.id}", params: { juncture: { name: "", description: "Updated modern world", faction_id: @ascended.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
      @modern.reload
      expect(@modern.name).to eq("Modern")
    end

    it "returns an error for invalid JSON string" do
      patch "/api/v2/junctures/#{@modern.id}", params: { juncture: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid juncture data format")
      @modern.reload
      expect(@modern.name).to eq("Modern")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/junctures/#{@modern.id}", params: { image: file, juncture: { name: "Updated Modern", description: "Updated modern world", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Modern")
      expect(body["image_url"]).not_to be_nil
      @modern.reload
      expect(@modern.image.attached?).to be_truthy
    end

    it "replaces an existing image" do
      @modern.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
      expect(@modern.image.attached?).to be_truthy
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/junctures/#{@modern.id}", params: { image: file, juncture: { name: "Updated Modern", description: "Updated modern world", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Modern")
      expect(body["image_url"]).not_to be_nil
      @modern.reload
      expect(@modern.image.attached?).to be_truthy
    end

    it "adds a character to a juncture" do
      patch "/api/v2/junctures/#{@ancient.id}", params: { juncture: { character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ancient")
      expect(body["character_ids"]).to include(@brick.id)
      @ancient.reload
      expect(@ancient.characters).to include(@brick)
    end

    it "removes a character from a juncture" do
      @ancient.characters << @brick
      patch "/api/v2/junctures/#{@ancient.id}", params: { juncture: { character_ids: [] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ancient")
      expect(body["character_ids"]).not_to include(@brick.id)
      @ancient.reload
      expect(@ancient.characters).not_to include(@brick)
    end
  end

  describe "GET /show" do
    it "retrieves a juncture with associations" do
      @modern.characters << @serena
      get "/api/v2/junctures/#{@modern.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Modern")
      expect(body["description"]).to eq("The modern world.")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["active"]).to eq(true)
      expect(body["character_ids"]).to include(@brick.id, @serena.id)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "description", "faction_id", "active", "image_url", "created_at", "updated_at", "character_ids")
    end

    it "returns a 404 for a non-existent juncture" do
      get "/api/v2/junctures/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a juncture with no associations" do
      delete "/api/v2/junctures/#{@future.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Juncture.exists?(@future.id)).to be_falsey
      expect { @future.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error for a juncture with character associations" do
      delete "/api/v2/junctures/#{@modern.id}", headers: @headers
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "associations" => true })
      expect(Juncture.exists?(@modern.id)).to be_truthy
    end

    it "returns an error for a juncture with vehicle associations" do
      delete "/api/v2/junctures/#{@ancient.id}", headers: @headers
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "associations" => true })
      expect(Juncture.exists?(@ancient.id)).to be_truthy
    end

    it "deletes a juncture with associations when force is true" do
      delete "/api/v2/junctures/#{@modern.id}", params: { force: true }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(Juncture.exists?(@modern.id)).to be_falsey
      expect { @modern.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(@brick.reload.juncture_id).to be_nil
      expect(@tank.reload.juncture_id).to be_nil
      expect(@dragons_party.reload.juncture_id).to be_nil
      expect(@dragons_hq.reload.juncture_id).to be_nil
    end

    it "returns an error for a non-existent juncture" do
      delete "/api/v2/junctures/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /remove_image" do
    it "removes an image from a juncture" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @modern.image.attach(image)
      expect(@modern.image.attached?).to be_truthy
      delete "/api/v2/junctures/#{@modern.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @modern.reload
      expect(@modern.image.attached?).to be_falsey
      expect(@modern.image_url).to be_nil
    end

    it "returns an error for a non-existent juncture" do
      delete "/api/v2/junctures/999999/image", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end
end
