require "rails_helper"
RSpec.describe "Api::V2::Factions", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    @outlaws = @campaign.factions.create!(name: "The Outlaws", description: "A group of rogues.")
    @inactive_faction = @campaign.factions.create!(name: "Inactive Faction", description: "A retired faction.", active: false)
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", faction_id: @dragons.id)
    @ancient = @campaign.junctures.create!(name: "Ancient", faction_id: @ascended.id)
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
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id)
    @jet = @campaign.vehicles.create!(name: "Jet", campaign_id: @campaign.id, faction_id: @ascended.id)
    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id, juncture_id: @modern.id)
    # sites
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", faction_id: @ascended.id, juncture_id: @modern.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new faction" do
      post "/api/v2/factions", params: { faction: { name: "New Faction", description: "A new faction", character_ids: [@brick.id], party_ids: [@dragons_party.id], site_ids: [@dragons_hq.id], juncture_ids: [@modern.id], vehicle_ids: [@tank.id] } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Faction")
      expect(body["description"]).to eq("A new faction")
      expect(body["character_ids"]).to include(@brick.id)
      expect(body["party_ids"]).to include(@dragons_party.id)
      expect(body["site_ids"]).to include(@dragons_hq.id)
      expect(body["juncture_ids"]).to include(@modern.id)
      expect(body["vehicle_ids"]).to include(@tank.id)
      expect(body["image_url"]).to be_nil
      expect(Faction.order("created_at").last.name).to eq("New Faction")
    end

    it "creates a new faction with JSON string" do
      post "/api/v2/factions", params: { faction: { name: "Json Faction", description: "A JSON faction", character_ids: [@serena.id], party_ids: [@ascended_party.id], site_ids: [@ascended_hq.id], juncture_ids: [@ancient.id], vehicle_ids: [@jet.id] }.to_json }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Faction")
      expect(body["description"]).to eq("A JSON faction")
      expect(body["character_ids"]).to include(@serena.id)
      expect(body["party_ids"]).to include(@ascended_party.id)
      expect(body["site_ids"]).to include(@ascended_hq.id)
      expect(body["juncture_ids"]).to include(@ancient.id)
      expect(body["vehicle_ids"]).to include(@jet.id)
      expect(Faction.order("created_at").last.name).to eq("Json Faction")
    end

    it "returns an error when the faction name is missing" do
      post "/api/v2/factions", params: { faction: { description: "A new faction", character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "returns an error for invalid JSON string" do
      post "/api/v2/factions", params: { faction: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid faction data format")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/factions", params: { image: file, faction: { name: "Faction with Image", description: "A faction with image", character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Faction with Image")
      expect(body["image_url"]).not_to be_nil
      expect(Faction.order("created_at").last.image.attached?).to be_truthy
    end
  end

  describe "PATCH /update" do
    it "updates an existing faction" do
      patch "/api/v2/factions/#{@dragons.id}", params: { faction: { name: "Updated Dragons", description: "Updated heroes", character_ids: [@serena.id], party_ids: [@ascended_party.id], site_ids: [@ascended_hq.id], juncture_ids: [@ancient.id], vehicle_ids: [@jet.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons")
      expect(body["description"]).to eq("Updated heroes")
      expect(body["character_ids"]).to include(@serena.id)
      expect(body["party_ids"]).to include(@ascended_party.id)
      expect(body["site_ids"]).to include(@ascended_hq.id)
      expect(body["juncture_ids"]).to include(@ancient.id)
      expect(body["vehicle_ids"]).to include(@jet.id)
      @dragons.reload
      expect(@dragons.name).to eq("Updated Dragons")
      expect(@dragons.characters).to include(@serena)
      expect(@dragons.parties).to include(@ascended_party)
      expect(@dragons.sites).to include(@ascended_hq)
      expect(@dragons.junctures).to include(@ancient)
      expect(@dragons.vehicles).to include(@jet)
    end

    it "updates an existing faction with JSON string" do
      patch "/api/v2/factions/#{@dragons.id}", params: { faction: { name: "Json Dragons", description: "JSON updated heroes", character_ids: [@serena.id], party_ids: [@ascended_party.id], site_ids: [@ascended_hq.id], juncture_ids: [@ancient.id], vehicle_ids: [@jet.id] }.to_json }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Dragons")
      expect(body["description"]).to eq("JSON updated heroes")
      expect(body["character_ids"]).to include(@serena.id)
      expect(body["party_ids"]).to include(@ascended_party.id)
      expect(body["site_ids"]).to include(@ascended_hq.id)
      expect(body["juncture_ids"]).to include(@ancient.id)
      expect(body["vehicle_ids"]).to include(@jet.id)
      @dragons.reload
      expect(@dragons.name).to eq("Json Dragons")
      expect(@dragons.characters).to include(@serena)
      expect(@dragons.parties).to include(@ascended_party)
      expect(@dragons.sites).to include(@ascended_hq)
      expect(@dragons.junctures).to include(@ancient)
      expect(@dragons.vehicles).to include(@jet)
    end

    it "returns an error when the faction name is missing" do
      patch "/api/v2/factions/#{@dragons.id}", params: { faction: { name: "", description: "Updated heroes", character_ids: [@serena.id] } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
      @dragons.reload
      expect(@dragons.name).to eq("The Dragons")
    end

    it "returns an error for invalid JSON string" do
      patch "/api/v2/factions/#{@dragons.id}", params: { faction: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid faction data format")
      @dragons.reload
      expect(@dragons.name).to eq("The Dragons")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/factions/#{@dragons.id}", params: { image: file, faction: { name: "Updated Dragons", description: "Updated heroes", character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons")
      expect(body["image_url"]).not_to be_nil
      @dragons.reload
      expect(@dragons.image.attached?).to be_truthy
    end

    it "replaces an existing image" do
      @dragons.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
      expect(@dragons.image.attached?).to be_truthy
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/factions/#{@dragons.id}", params: { image: file, faction: { name: "Updated Dragons", description: "Updated heroes", character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons")
      expect(body["image_url"]).not_to be_nil
      @dragons.reload
      expect(@dragons.image.attached?).to be_truthy
    end

    it "adds a character to a faction" do
      patch "/api/v2/factions/#{@ascended.id}", params: { faction: { character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Ascended")
      expect(body["character_ids"]).to include(@brick.id)
      @ascended.reload
      expect(@ascended.characters).to include(@brick)
    end

    it "removes a character from a faction" do
      @ascended.characters << @brick
      patch "/api/v2/factions/#{@ascended.id}", params: { faction: { character_ids: [] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Ascended")
      expect(body["character_ids"]).not_to include(@brick.id)
      @ascended.reload
      expect(@ascended.characters).not_to include(@brick)
    end

    it "adds a vehicle to a faction" do
      patch "/api/v2/factions/#{@outlaws.id}", params: { faction: { vehicle_ids: [@tank.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Outlaws")
      expect(body["vehicle_ids"]).to include(@tank.id)
      @outlaws.reload
      expect(@outlaws.vehicles).to include(@tank)
    end

    it "removes a vehicle from a faction" do
      @outlaws.vehicles << @tank
      patch "/api/v2/factions/#{@outlaws.id}", params: { faction: { vehicle_ids: [] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Outlaws")
      expect(body["vehicle_ids"]).not_to include(@tank.id)
      @outlaws.reload
      expect(@outlaws.vehicles).not_to include(@tank)
    end
  end

  describe "GET /show" do
    it "retrieves a faction with associations" do
      @dragons.characters << @serena
      @dragons.parties << @ascended_party
      @dragons.sites << @ascended_hq
      @dragons.junctures << @ancient
      @dragons.vehicles << @jet
      get "/api/v2/factions/#{@dragons.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Dragons")
      expect(body["description"]).to eq("A bunch of heroes.")
      expect(body["active"]).to eq(true)
      expect(body["image_url"]).to be_nil
      expect(body["character_ids"]).to include(@brick.id, @serena.id)
      expect(body["party_ids"]).to include(@dragons_party.id, @ascended_party.id)
      expect(body["site_ids"]).to include(@dragons_hq.id, @ascended_hq.id)
      expect(body["juncture_ids"]).to include(@modern.id, @ancient.id)
      expect(body["vehicle_ids"]).to include(@tank.id, @jet.id)
      expect(body.keys).to include("id", "name", "description", "active", "image_url", "created_at", "updated_at", "character_ids", "party_ids", "site_ids", "juncture_ids", "vehicle_ids")
    end

    it "returns a 404 for a non-existent faction" do
      get "/api/v2/factions/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a faction with no character or vehicle associations" do
      delete "/api/v2/factions/#{@outlaws.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Faction.exists?(@outlaws.id)).to be_falsey
      expect { @outlaws.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error for a faction with character associations" do
      delete "/api/v2/factions/#{@dragons.id}", headers: @headers
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "characters" => true })
      expect(Faction.exists?(@dragons.id)).to be_truthy
    end

    it "returns an error for a faction with vehicle associations" do
      delete "/api/v2/factions/#{@ascended.id}", headers: @headers
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "vehicles" => true })
      expect(Faction.exists?(@ascended.id)).to be_truthy
    end

    it "deletes a faction with associations when force is true" do
      delete "/api/v2/factions/#{@dragons.id}", params: { force: true }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(Faction.exists?(@dragons.id)).to be_falsey
      expect { @dragons.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(@brick.reload.faction_id).to be_nil
      expect(@serena.reload.faction_id).to be_nil
      expect(@tank.reload.faction_id).to be_nil
      expect(@dragons_party.reload.faction_id).to be_nil
      expect(@dragons_hq.reload.faction_id).to be_nil
      expect(@modern.reload.faction_id).to be_nil
    end

    it "returns an error for a non-existent faction" do
      delete "/api/v2/factions/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /image" do
    it "removes an image from a faction" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @dragons.image.attach(image)
      expect(@dragons.image.attached?).to be_truthy
      delete "/api/v2/factions/#{@dragons.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @dragons.reload
      expect(@dragons.image.attached?).to be_falsey
      expect(@dragons.image_url).to be_nil
    end

    it "returns an error for a non-existent faction" do
      delete "/api/v2/factions/999999/image", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end
end
