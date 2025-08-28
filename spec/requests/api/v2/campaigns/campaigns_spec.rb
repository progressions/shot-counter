require "rails_helper"
RSpec.describe "Api::V2::Campaigns", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    User.destroy_all
    Campaign.destroy_all
    Character.destroy_all
    # users
    @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true, first_name: "Admin", last_name: "User", name: "Admin User")
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master", name: "Game Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One", name: "Player One")
    # campaigns
    @campaign = @gamemaster.campaigns.create!(name: "Adventure", description: "Epic adventure", active: true, user_ids: [@player.id])
    @other_campaign = @gamemaster.campaigns.create!(name: "Quest", description: "Heroic quest", active: true)
    @inactive_campaign = @gamemaster.campaigns.create!(name: "Old Campaign", description: "Retired campaign", active: false)
    # admin campaigns for testing admin access
    @admin_campaign = @admin.campaigns.create!(name: "Admin Campaign", description: "Admin test campaign", active: true)
    @admin_campaign2 = @admin.campaigns.create!(name: "Admin Campaign 2", description: "Second admin test campaign", active: true)
    @admin_campaign3 = @admin.campaigns.create!(name: "Admin Campaign 3", description: "Third admin test campaign", active: true)
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
        expect(response).to have_http_status(:unprocessable_content)
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

      context "when updating active status" do
        it "sets active to false" do
          patch "/api/v2/campaigns/#{@campaign.id}", params: { campaign: { active: false } }, headers: @gamemaster_headers
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["active"]).to eq(false)
          @campaign.reload
          expect(@campaign.active).to eq(false)
        end

        it "sets active to true" do
          @inactive_campaign.update!(active: false)
          patch "/api/v2/campaigns/#{@inactive_campaign.id}", params: { campaign: { active: true } }, headers: @gamemaster_headers
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["active"]).to eq(true)
          @inactive_campaign.reload
          expect(@inactive_campaign.active).to eq(true)
        end
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

      it "returns a unified error response for a campaign with associations" do
        delete "/api/v2/campaigns/#{@other_campaign.id}", headers: @gamemaster_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error_type"]).to eq("associations_exist")
        expect(body["entity_type"]).to eq("campaign")
        expect(body["entity_id"]).to eq(@other_campaign.id)
        expect(body["constraints"]).to have_key("characters")
        expect(body["constraints"]["characters"]["count"]).to be > 0
        expect(body["suggestions"]).to include("Use force=true parameter to cascade delete")
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

  describe "GET /index" do
    context "when user is gamemaster" do
      it "retrieves campaigns list" do
        get "/api/v2/campaigns", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["campaigns"]).to be_an(Array)
        expect(body["campaigns"].length).to be >= 2
        expect(body["campaigns"].any? { |c| c["name"] == "Adventure" }).to be_truthy
        expect(body["campaigns"].any? { |c| c["name"] == "Quest" }).to be_truthy
        expect(body).to have_key("meta")
      end

      it "supports pagination" do
        get "/api/v2/campaigns?page=1&per_page=1", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["campaigns"]).to be_an(Array)
        expect(body["campaigns"].length).to eq(1)
        expect(body["meta"]).to have_key("total_pages")
        expect(body["meta"]).to have_key("current_page")
      end

      it "supports sorting" do
        get "/api/v2/campaigns?sort=name&order=asc", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        campaign_names = body["campaigns"].map { |c| c["name"] }
        expect(campaign_names).to eq(campaign_names.sort)
      end

      it "supports search" do
        get "/api/v2/campaigns?search=Adventure", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["campaigns"]).to be_an(Array)
        expect(body["campaigns"].all? { |c| c["name"].include?("Adventure") }).to be_truthy
      end

      context "performance requirements" do
        before do
          # Create additional campaigns for performance testing
          5.times do |i|
            campaign = @gamemaster.campaigns.create!(
              name: "Performance Test Campaign #{i}",
              description: "Campaign for performance testing",
              active: true,
              user_ids: [@player.id]
            )
            # Add related data to test JOIN performance
            2.times do |j|
              Character.create!(
                name: "Character #{i}-#{j}",
                action_values: { "Type" => "PC", "Archetype" => "Hero" },
                campaign_id: campaign.id,
                user_id: @gamemaster.id
              )
              campaign.vehicles.create!(
                name: "Vehicle #{i}-#{j}",
                action_values: { "Type" => "Vehicle", "Speed" => 10 }
              )
            end
          end
        end

        it "responds within performance targets" do
          start_time = Time.current
          get "/api/v2/campaigns", headers: @gamemaster_headers
          end_time = Time.current
          response_time = ((end_time - start_time) * 1000).round(2)

          expect(response).to have_http_status(:ok)
          expect(response_time).to be < 500.0, "Response time was #{response_time}ms, should be < 500ms"
        end

        it "performs efficiently with pagination" do
          start_time = Time.current
          get "/api/v2/campaigns?page=1&per_page=15", headers: @gamemaster_headers
          end_time = Time.current
          response_time = ((end_time - start_time) * 1000).round(2)

          expect(response).to have_http_status(:ok)
          expect(response_time).to be < 500.0, "Paginated response time was #{response_time}ms, should be < 500ms"
        end

        it "performs efficiently with search" do
          start_time = Time.current
          get "/api/v2/campaigns?search=Test", headers: @gamemaster_headers
          end_time = Time.current
          response_time = ((end_time - start_time) * 1000).round(2)

          expect(response).to have_http_status(:ok)
          expect(response_time).to be < 500.0, "Search response time was #{response_time}ms, should be < 500ms"
        end

        it "executes reasonable number of database queries" do
          # Test for query efficiency (basic count without specific gem)
          query_count = 0
          callback = ->(name, started, finished, unique_id, payload) {
            query_count += 1 if payload[:name] == "SQL" && !payload[:sql].include?("SCHEMA")
          }
          
          ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
            get "/api/v2/campaigns", headers: @gamemaster_headers
          end
          
          expect(response).to have_http_status(:ok)
          expect(query_count).to be < 50, "Executed #{query_count} queries, should be < 50"
        end

        it "includes essential data without over-fetching" do
          get "/api/v2/campaigns", headers: @gamemaster_headers
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          
          campaign = body["campaigns"].first
          essential_keys = ["id", "name", "description", "active", "created_at", "updated_at"]
          essential_keys.each do |key|
            expect(campaign).to have_key(key), "Missing essential key: #{key}"
          end

          # Should not include expensive association data in index view
          expect(campaign).to_not have_key("characters")
          expect(campaign).to_not have_key("vehicles")
          expect(campaign).to_not have_key("fights")
        end
      end
    end

    context "when user is admin" do
      it "retrieves all campaigns" do
        get "/api/v2/campaigns", headers: @admin_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["campaigns"]).to be_an(Array)
        expect(body["campaigns"].length).to be >= 3
      end
    end

    context "when user is player" do
      it "retrieves only campaigns they are members of" do
        get "/api/v2/campaigns", headers: @player_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["campaigns"]).to be_an(Array)
        campaign_names = body["campaigns"].map { |c| c["name"] }
        expect(campaign_names).to include("Adventure")
        expect(campaign_names).to_not include("Quest")
      end
    end

    context "when user is unauthenticated" do
      it "returns unauthorized" do
        get "/api/v2/campaigns"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
