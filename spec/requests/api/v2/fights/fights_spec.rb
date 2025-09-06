require "rails_helper"
RSpec.describe "Api::V2::Fights", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
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
    # vehicles
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id, juncture_id: @modern.id, user_id: @player.id)
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    context "when user is authenticated" do
      it "creates a new fight with season and session" do
        post "/api/v2/fights", params: { fight: { name: "New Fight", description: "A new battle", season: 3, session: 4, character_ids: [@brick.id], vehicle_ids: [@tank.id] } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("New Fight")
        expect(body["description"]).to eq("A new battle")
        expect(body["season"]).to eq(3)
        expect(body["session"]).to eq(4)
        expect(body["character_ids"]).to include(@brick.id)
        expect(body["vehicle_ids"]).to include(@tank.id)
        expect(body["image_url"]).to be_nil
        expect(Fight.order("created_at").last.name).to eq("New Fight")
      end

      it "creates a new fight with JSON string including season and session" do
        post "/api/v2/fights", params: { fight: { name: "Json Fight", description: "A JSON battle", season: 2, session: 3, character_ids: [@serena.id] }.to_json }, headers: @gamemaster_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Json Fight")
        expect(body["season"]).to eq(2)
        expect(body["session"]).to eq(3)
        expect(body["character_ids"]).to include(@serena.id)
        expect(Fight.order("created_at").last.name).to eq("Json Fight")
      end

      it "returns an error when name is missing" do
        post "/api/v2/fights", params: { fight: { description: "A new battle", season: 3, session: 4 } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("name" => ["can't be blank"])
      end

      it "returns an error for invalid JSON string" do
        post "/api/v2/fights", params: { fight: "invalid json" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid fight data format")
      end

      it "attaches an image", skip: "Image processing disabled in test environment" do
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        post "/api/v2/fights", params: { image: file, fight: { name: "Fight with Image", description: "A fight with image", season: 3, session: 4 } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Fight with Image")
        expect(body["season"]).to eq(3)
        expect(body["session"]).to eq(4)
        expect(body["image_url"]).not_to be_nil
        expect(Fight.order("created_at").last.image.attached?).to be_truthy
      end
    end
  end

  describe "GET /show" do
    it "retrieves a fight with season and session" do
      get "/api/v2/fights/#{@brawl.id}", headers: @gamemaster_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Big Brawl")
      expect(body["description"]).to eq("A large fight in the city.")
      expect(body["season"]).to eq(1)
      expect(body["session"]).to eq(1)
      expect(body["started_at"]).not_to be_nil
      expect(body["ended_at"]).to be_nil
      expect(body["active"]).to be true
      expect(body.keys).to include("id", "name", "description", "campaign_id", "started_at", "ended_at", "created_at", "updated_at", "active", "season", "session", "character_ids", "vehicle_ids", "entity_class", "image_positions")
    end

    it "returns a 404 for a non-existent fight" do
      get "/api/v2/fights/999999", headers: @gamemaster_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /update" do
    context "when user is authenticated" do
      it "updates a fight’s attributes including season and session" do
        patch "/api/v2/fights/#{@brawl.id}", params: { fight: { name: "Updated Brawl", description: "Updated fight", season: 4, session: 5, character_ids: [@brick.id], vehicle_ids: [@tank.id] } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Updated Brawl")
        expect(body["description"]).to eq("Updated fight")
        expect(body["season"]).to eq(4)
        expect(body["session"]).to eq(5)
        expect(body["character_ids"]).to include(@brick.id)
        expect(body["vehicle_ids"]).to include(@tank.id)
        @brawl.reload
        expect(@brawl.name).to eq("Updated Brawl")
        expect(@brawl.season).to eq(4)
        expect(@brawl.session).to eq(5)
      end

      it "updates a fight with JSON string including season and session" do
        patch "/api/v2/fights/#{@brawl.id}", params: { fight: { name: "Json Brawl", description: "JSON fight", season: 3, session: 2, character_ids: [@serena.id] }.to_json }, headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Json Brawl")
        expect(body["season"]).to eq(3)
        expect(body["session"]).to eq(2)
        expect(body["character_ids"]).to include(@serena.id)
        @brawl.reload
        expect(@brawl.name).to eq("Json Brawl")
        expect(@brawl.season).to eq(3)
        expect(@brawl.session).to eq(2)
      end

      it "returns an error when name is missing" do
        patch "/api/v2/fights/#{@brawl.id}", params: { fight: { name: "", description: "Updated fight", season: 4, session: 5 } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("name" => ["can't be blank"])
        @brawl.reload
        expect(@brawl.name).to eq("Big Brawl")
      end

      it "returns an error for invalid JSON string" do
        patch "/api/v2/fights/#{@brawl.id}", params: { fight: "invalid json" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid fight data format")
        @brawl.reload
        expect(@brawl.name).to eq("Big Brawl")
      end

      it "attaches an image", skip: "Image processing disabled in test environment" do
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        patch "/api/v2/fights/#{@brawl.id}", params: { image: file, fight: { name: "Image Brawl", description: "Fight with image", season: 3, session: 4 } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Image Brawl")
        expect(body["season"]).to eq(3)
        expect(body["session"]).to eq(4)
        expect(body["image_url"]).not_to be_nil
        @brawl.reload
        expect(@brawl.image.attached?).to be_truthy
      end

      it "replaces an existing image", skip: "Image processing disabled in test environment" do
        @brawl.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
        expect(@brawl.image.attached?).to be_truthy
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        patch "/api/v2/fights/#{@brawl.id}", params: { image: file, fight: { name: "Image Brawl", description: "Fight with image", season: 3, session: 4 } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Image Brawl")
        expect(body["season"]).to eq(3)
        expect(body["session"]).to eq(4)
        expect(body["image_url"]).not_to be_nil
        @brawl.reload
        expect(@brawl.image.attached?).to be_truthy
      end

      context "when updating active status" do
        it "sets active to false" do
          patch "/api/v2/fights/#{@brawl.id}", params: { fight: { active: false } }, headers: @gamemaster_headers
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body["active"]).to eq(false)
          @brawl.reload
          expect(@brawl.active).to eq(false)
        end

        it "sets active to true" do
          @skirmish.update!(active: false)
          patch "/api/v2/fights/#{@skirmish.id}", params: { fight: { active: true } }, headers: @gamemaster_headers
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body["active"]).to eq(true)
          @skirmish.reload
          expect(@skirmish.active).to eq(true)
        end
      end
    end

    context "when fight does not exist" do
      it "returns a 404 error" do
        patch "/api/v2/fights/999999", params: { fight: { name: "Nonexistent" } }, headers: @gamemaster_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user is authenticated" do
      it "deletes a fight" do
        delete "/api/v2/fights/#{@brawl.id}", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        expect(Fight.exists?(@brawl.id)).to be_falsey
        expect { @brawl.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "returns a 404 for a non-existent fight" do
        delete "/api/v2/fights/999999", headers: @gamemaster_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /touch" do
    context "when user is authenticated" do
      it "touches a fight and triggers broadcast update" do
        # Mock the broadcast_update method to verify it's called
        expect_any_instance_of(Fight).to receive(:broadcast_update)
        
        patch "/api/v2/fights/#{@brawl.id}/touch", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Big Brawl")
        expect(body["id"]).to eq(@brawl.id)
      end

      it "returns a 404 for a non-existent fight" do
        patch "/api/v2/fights/999999/touch", headers: @gamemaster_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /remove_image" do
    context "when user is authenticated" do
      it "removes a fight's image" do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @brawl.image.attach(image)
        expect(@brawl.image.attached?).to be_truthy
        delete "/api/v2/fights/#{@brawl.id}/image", headers: @gamemaster_headers
        expect(response).to have_http_status(:ok)
        @brawl.reload
        expect(@brawl.image.attached?).to be_falsey
        expect(@brawl.image_url).to be_nil
      end

      it "returns a 404 for a non-existent fight" do
        delete "/api/v2/fights/999999/image", headers: @gamemaster_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
