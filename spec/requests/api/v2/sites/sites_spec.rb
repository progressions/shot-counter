require "rails_helper"
RSpec.describe "Api::V2::Sites", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")
    # sites
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", description: "The Dragons' headquarters.", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", description: "The Ascended's headquarters.", faction_id: @ascended.id, juncture_id: @modern.id)
    @bandit_hideout = @campaign.sites.create!(name: "Bandit Hideout", description: "Where the bandits hang out.", faction_id: nil, juncture_id: @ancient.id)
    @stone_circle = @campaign.sites.create!(name: "Stone Circle", description: "An ancient stone circle.", faction_id: nil, juncture_id: @ancient.id, active: false)
    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)
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
    @brick.sites << @dragons_hq
    @serena.sites << @stone_circle
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new site" do
      post "/api/v2/sites", params: { site: { name: "New Site", description: "A new site", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Site")
      expect(body["description"]).to eq("A new site")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["active"]).to eq(true)
      expect(body["image_url"]).to be_nil
      expect(Site.order("created_at").last.name).to eq("New Site")
    end

    it "creates a new site with JSON string" do
      post "/api/v2/sites", params: { site: { name: "Json Site", description: "A JSON site", faction_id: @ascended.id, active: true }.to_json }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Site")
      expect(body["description"]).to eq("A JSON site")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(true)
      expect(Site.order("created_at").last.name).to eq("Json Site")
    end

    it "returns an error when the site name is missing" do
      post "/api/v2/sites", params: { site: { description: "A new site", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "returns an error for invalid JSON string" do
      post "/api/v2/sites", params: { site: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid site data format")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/sites", params: { image: file, site: { name: "Site with Image", description: "A site with image", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Site with Image")
      expect(body["image_url"]).not_to be_nil
      expect(Site.order("created_at").last.image.attached?).to be_truthy
    end
  end

  describe "PATCH /update" do
    it "updates an existing site" do
      patch "/api/v2/sites/#{@dragons_hq.id}", params: { site: { name: "Updated Dragons HQ", description: "Updated headquarters", faction_id: @ascended.id, active: false, character_ids: [@serena.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons HQ")
      expect(body["description"]).to eq("Updated headquarters")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(false)
      @dragons_hq.reload
      expect(@dragons_hq.name).to eq("Updated Dragons HQ")
      expect(@dragons_hq.description).to eq("Updated headquarters")
      expect(@dragons_hq.faction_id).to eq(@ascended.id)
      expect(@dragons_hq.characters).to include(@serena)
    end

    it "updates an existing site with JSON string" do
      patch "/api/v2/sites/#{@dragons_hq.id}", params: { site: { name: "Json Dragons HQ", description: "JSON updated headquarters", faction_id: @ascended.id, active: false, character_ids: [@serena.id] }.to_json }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Dragons HQ")
      expect(body["description"]).to eq("JSON updated headquarters")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(false)
      @dragons_hq.reload
      expect(@dragons_hq.name).to eq("Json Dragons HQ")
      expect(@dragons_hq.characters).to include(@serena)
    end

    it "returns an error when the site name is missing" do
      patch "/api/v2/sites/#{@dragons_hq.id}", params: { site: { name: "", description: "Updated headquarters", faction_id: @ascended.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
      @dragons_hq.reload
      expect(@dragons_hq.name).to eq("Dragons HQ")
    end

    it "returns an error for invalid JSON string" do
      patch "/api/v2/sites/#{@dragons_hq.id}", params: { site: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid site data format")
      @dragons_hq.reload
      expect(@dragons_hq.name).to eq("Dragons HQ")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/sites/#{@dragons_hq.id}", params: { image: file, site: { name: "Updated Dragons HQ", description: "Updated headquarters", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons HQ")
      expect(body["image_url"]).not_to be_nil
      @dragons_hq.reload
      expect(@dragons_hq.image.attached?).to be_truthy
    end

    it "replaces an existing image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @dragons_hq.image.attach(file)
      expect(@dragons_hq.image.attached?).to be_truthy
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/sites/#{@dragons_hq.id}", params: { image: file, site: { name: "Updated Dragons HQ", description: "Updated headquarters", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons HQ")
      expect(body["image_url"]).not_to be_nil
      @dragons_hq.reload
      expect(@dragons_hq.image.attached?).to be_truthy
    end

    context "when updating active status" do
      it "sets active to false" do
        patch "/api/v2/sites/#{@dragons_hq.id}", params: { site: { active: false } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(false)
        @dragons_hq.reload
        expect(@dragons_hq.active).to eq(false)
      end

      it "sets active to true" do
        @bandit_hideout.update!(active: false)
        patch "/api/v2/sites/#{@bandit_hideout.id}", params: { site: { active: true } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(true)
        @bandit_hideout.reload
        expect(@bandit_hideout.active).to eq(true)
      end
    end
  end

  describe "GET /show" do
    it "retrieves a site" do
      get "/api/v2/sites/#{@dragons_hq.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Dragons HQ")
      expect(body["description"]).to eq("The Dragons' headquarters.")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["juncture_id"]).to eq(@modern.id)
      expect(body["active"]).to eq(true)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "description", "faction_id", "juncture_id", "active", "image_url", "created_at", "updated_at")
    end

    it "returns a 404 for a non-existent site" do
      get "/api/v2/sites/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a site with no attunements" do
      delete "/api/v2/sites/#{@bandit_hideout.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Site.exists?(@bandit_hideout.id)).to be_falsey
      expect { @bandit_hideout.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error for a site with attunements" do
      delete "/api/v2/sites/#{@dragons_hq.id}", headers: @headers
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "attunements" => true })
      expect(Site.exists?(@dragons_hq.id)).to be_truthy
    end

    it "deletes a site" do
      delete "/api/v2/sites/#{@bandit_hideout.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Site.exists?(@bandit_hideout.id)).to be_falsey
      expect { @bandit_hideout.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes a site with attunements" do
      delete "/api/v2/sites/#{@dragons_hq.id}", params: { force: true }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(Site.exists?(@dragons_hq.id)).to be_falsey
      expect { @dragons_hq.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(@brick.reload.sites).not_to include(@dragons_hq)
    end

    it "returns an error for a non-existent site" do
      delete "/api/v2/sites/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /image" do
    it "removes an image from a site" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @dragons_hq.image.attach(image)
      expect(@dragons_hq.image.attached?).to be_truthy
      delete "/api/v2/sites/#{@dragons_hq.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @dragons_hq.reload
      expect(@dragons_hq.image.attached?).to be_falsey
      expect(@dragons_hq.image_url).to be_nil
    end

    it "returns an error for a non-existent site" do
      delete "/api/v2/sites/999999/image", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end
end
