require "rails_helper"
RSpec.describe "Api::V2::Campaigns", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # users
    @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true, first_name: "Admin", last_name: "User", name: "Admin User")
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master", name: "Game Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One", name: "Player One")
    # campaigns
    @campaign = @gamemaster.campaigns.create!(name: "Adventure", description: "Epic adventure", active: true, user_ids: [@player.id])
    @other_campaign = @gamemaster.campaigns.create!(name: "Quest", description: "Heroic quest", active: true)
    @inactive_campaign = @gamemaster.campaigns.create!(name: "Old Campaign", description: "Retired campaign", active: false)
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
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
    @other_character = Character.create!(
      name: "Other Hero",
      action_values: { "Type" => "PC", "Archetype" => "Hero" },
      campaign_id: @other_campaign.id,
      faction_id: nil,
      juncture_id: nil,
      user_id: @player.id,
    )
    # vehicles
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id, juncture_id: @modern.id)
    @admin_headers = Devise::JWT::TestHelpers.auth_headers({}, @admin)
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    context "when user is gamemaster" do
      it "creates a new campaign" do
        post "/api/v2/campaigns", params: { campaign: { name: "New Campaign", description: "A new adventure", active: true, user_ids: [@player.id] } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("New Campaign")
        expect(body["description"]).to eq("A new adventure")
        expect(body["active"]).to eq(true)
        expect(body["user_ids"]).to include(@player.id)
        expect(body["image_url"]).to be_nil
        expect(Campaign.order("created_at").last.name).to eq("New Campaign")
      end

      it "creates a new campaign with JSON string" do
        post "/api/v2/campaigns", params: { campaign: { name: "Json Campaign", description: "A JSON adventure", active: false, user_ids: [@player.id] }.to_json }, headers: @gamemaster_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Json Campaign")
        expect(body["description"]).to eq("A JSON adventure")
        expect(body["active"]).to eq(false)
        expect(body["user_ids"]).to include(@player.id)
        expect(Campaign.order("created_at").last.name).to eq("Json Campaign")
      end

      it "returns an error when name is missing" do
        post "/api/v2/campaigns", params: { campaign: { description: "A new adventure", active: true, user_ids: [@player.id] } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include({ "name" => ["can't be blank"] })
      end

      it "returns an error for invalid JSON string" do
        post "/api/v2/campaigns", params: { campaign: "invalid json" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid campaign data format")
      end

      it "attaches an image" do
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        post "/api/v2/campaigns", params: { image: file, campaign: { name: "Campaign with Image", description: "A campaign with image", active: true } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Campaign with Image")
        expect(body["image_url"]).not_to be_nil
        expect(Campaign.order("created_at").last.image.attached?).to be_truthy
      end
    end

    context "when user is admin" do
      it "creates a new campaign" do
        post "/api/v2/campaigns", params: { campaign: { name: "Admin Campaign", description: "Admin adventure", active: true, user_ids: [@player.id] } }, headers: @admin_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Admin Campaign")
        expect(body["user_ids"]).to include(@player.id)
        expect(Campaign.order("created_at").last.name).to eq("Admin Campaign")
      end
    end

    context "when user is not gamemaster or admin" do
      it "returns a forbidden error" do
        post "/api/v2/campaigns", params: { campaign: { name: "New Campaign", description: "A new adventure" } }, headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Gamemaster or admin access required")
      end
    end
  end

  describe "GET /show" do
    context "when user is gamemaster" do
      it "retrieves a campaign by id" do
        get "/api/v2/campaigns/#{@campaign.id}", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Adventure")
        expect(body["description"]).to eq("Epic adventure")
        expect(body["active"]).to eq(true)
        expect(body["user_ids"]).to include(@player.id)
        expect(body["image_url"]).to be_nil
        expect(body.keys).to include("id", "name", "description", "active", "user_ids", "image_url", "created_at", "updated_at")
      end

      it "retrieves the current campaign" do
        get "/api/v2/campaigns/current", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Adventure")
        expect(body["user_ids"]).to include(@player.id)
      end
    end

    context "when user is admin" do
      it "retrieves any campaign" do
        get "/api/v2/campaigns/#{@campaign.id}", headers: @admin_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Adventure")
        expect(body["user_ids"]).to include(@player.id)
      end
    end

    context "when user is a player in the campaign" do
      it "retrieves the campaign" do
        get "/api/v2/campaigns/#{@campaign.id}", headers: @player_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Adventure")
      end
    end

    context "when user is unauthorized" do
      it "returns a 404 for a campaign they don’t own or play" do
        get "/api/v2/campaigns/#{@other_campaign.id}", headers: @player_headers
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Record not found or unauthorized")
      end
    end
  end

  describe "PATCH /update" do
    context "when user is gamemaster" do
      it "updates a campaign" do
        patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: { name: "Updated Adventure", description: "Updated epic adventure", active: false, user_ids: [] } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Updated Adventure")
        expect(body["description"]).to eq("Updated epic adventure")
        expect(body["active"]).to eq(false)
        expect(body["user_ids"]).to eq([])
        @campaign.reload
        expect(@campaign.name).to eq("Updated Adventure")
      end

      it "updates a campaign with JSON string" do
        patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: { name: "Json Adventure", description: "JSON epic adventure", active: true, user_ids: [@gamemaster.id] }.to_json }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Json Adventure")
        expect(body["user_ids"]).to include(@gamemaster.id)
        @campaign.reload
        expect(@campaign.name).to eq("Json Adventure")
      end

      it "returns an error when name is missing" do
        patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: { name: "", description: "Updated adventure" } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include({ "name" => ["can't be blank"] })
        @campaign.reload
        expect(@campaign.name).to eq("Adventure")
      end

      it "returns an error for invalid JSON string" do
        patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: "invalid json" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid campaign data format")
        @campaign.reload
        expect(@campaign.name).to eq("Adventure")
      end

      it "attaches an image" do
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        patch "/api/v2/campaigns/#{@campaign.id}", params: { image: file, campaign: { name: "Image Adventure", description: "Adventure with image" } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Image Adventure")
        expect(body["image_url"]).not_to be_nil
        @campaign.reload
        expect(@campaign.image.attached?).to be_truthy
      end

      it "replaces an existing image" do
        @campaign.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
        expect(@campaign.image.attached?).to be_truthy
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        patch "/api/v2/campaigns/#{@campaign.id}", params: { image: file, campaign: { name: "Image Adventure", description: "Adventure with image" } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Image Adventure")
        expect(body["image_url"]).not_to be_nil
        @campaign.reload
        expect(@campaign.image.attached?).to be_truthy
      end
    end

    context "when user is admin" do
      it "updates any campaign" do
        patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: { name: "Admin Updated", description: "Admin update", active: false } }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Admin Updated")
        @campaign.reload
        expect(@campaign.name).to eq("Admin Updated")
      end
    end

    context "when user is not gamemaster or admin" do
      it "returns forbidden" do
        patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: { name: "Unauthorized Update" } }, headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Gamemaster or admin access required")
        @campaign.reload
        expect(@campaign.name).to eq("Adventure")
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user is gamemaster" do
      it "deletes a campaign with no associations" do
        delete "/api/v2/campaigns/#{@inactive_campaign.id}", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        expect(Campaign.exists?(@inactive_campaign.id)).to be_falsey
        expect { @inactive_campaign.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "returns an error for a campaign with associations" do
        delete "/api/v2/campaigns/#{@other_campaign.id}", headers: @gamemaster_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["errors"]).to eq({ "associations" => true })
        expect(Campaign.exists?(@other_campaign.id)).to be_truthy
      end

      it "deletes a campaign with associations when force is true" do
        delete "/api/v2/campaigns/#{@other_campaign.id}", params: { force: true }, headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        expect(Campaign.exists?(@other_campaign.id)).to be_falsey
        expect { @other_campaign.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(@other_character.reload.campaign_id).to be_nil
      end

      it "returns an error for the current campaign" do
        delete "/api/v2/campaigns/#{@campaign.id}", headers: @gamemaster_headers
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Cannot destroy the current campaign")
        expect(Campaign.exists?(@campaign.id)).to be_truthy
      end
    end

    context "when user is admin" do
      it "deletes any campaign with no associations" do
        delete "/api/v2/campaigns/#{@inactive_campaign.id}", headers: @admin_headers
        expect(response).to have_http_status(:ok)
        expect(Campaign.exists?(@inactive_campaign.id)).to be_falsey
        expect { @inactive_campaign.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deletes any campaign with associations when force is true" do
        delete "/api/v2/campaigns/#{@other_campaign.id}", params: { force: true }, headers: @admin_headers
        expect(response).to have_http_status(:ok)
        expect(Campaign.exists?(@other_campaign.id)).to be_falsey
        expect { @other_campaign.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(@other_character.reload.campaign_id).to be_nil
      end

      it "returns an error for the current campaign" do
        CurrentCampaign.set(user: @admin, campaign: @campaign)
        delete "/api/v2/campaigns/#{@campaign.id}", headers: @admin_headers
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Cannot destroy the current campaign")
        expect(Campaign.exists?(@campaign.id)).to be_truthy
      end
    end

    context "when user is not gamemaster or admin" do
      it "returns a forbidden error" do
        delete "/api/v2/campaigns/#{@other_campaign.id}", headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Gamemaster or admin access required")
        expect(Campaign.exists?(@other_campaign.id)).to be_truthy
      end
    end
  end

  describe "DELETE /remove_image" do
    context "when user is gamemaster" do
      it "removes a campaign’s image" do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @campaign.image.attach(image)
        expect(@campaign.image.attached?).to be_truthy
        delete "/api/v2/campaigns/#{@campaign.id}/image", headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["image_url"]).to be_nil
        @campaign.reload
        expect(@campaign.image.attached?).to be_falsey
        expect(@campaign.image_url).to be_nil
      end
    end

    context "when user is admin" do
      it "removes any campaign’s image" do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @campaign.image.attach(image)
        expect(@campaign.image.attached?).to be_truthy
        delete "/api/v2/campaigns/#{@campaign.id}/image", headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["image_url"]).to be_nil
        @campaign.reload
        expect(@campaign.image.attached?).to be_falsey
        expect(@campaign.image_url).to be_nil
      end
    end

    context "when user is not gamemaster or admin" do
      it "returns a forbidden error" do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @campaign.image.attach(image)
        expect(@campaign.image.attached?).to be_truthy
        delete "/api/v2/campaigns/#{@campaign.id}/image", headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Gamemaster or admin access required")
        @campaign.reload
        expect(@campaign.image.attached?).to be_truthy
      end
    end

    it "returns an error for a non-existent campaign" do
      delete "/api/v2/campaigns/999999/image", headers: @admin_headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found or unauthorized")
    end
  end
end
