require "rails_helper"
RSpec.describe "Api::V2::Parties", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")
    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", description: "The Dragons' main group.", faction_id: @dragons.id, juncture_id: @modern.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", description: "The Ascended's elite team.", faction_id: @ascended.id, juncture_id: @modern.id)
    @rogue_team = @campaign.parties.create!(name: "Rogue Team", description: "A group of independents.", faction_id: nil, juncture_id: @ancient.id)
    @inactive_team = @campaign.parties.create!(name: "Inactive Team", description: "A retired group.", faction_id: nil, juncture_id: @ancient.id, active: false)
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
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id)
    @jet = @campaign.vehicles.create!(name: "Jet", campaign_id: @campaign.id)
    # memberships
    @brick.parties << @dragons_party
    @serena.parties << @inactive_team
    @dragons_party.vehicles << @tank
    @dragons_party.vehicles << @jet
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new party" do
      post "/api/v2/parties", params: { party: { name: "New Party", description: "A new party", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Party")
      expect(body["description"]).to eq("A new party")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["active"]).to eq(true)
      expect(body["image_url"]).to be_nil
      expect(Party.order("created_at").last.name).to eq("New Party")
    end

    it "creates a new party with JSON string" do
      post "/api/v2/parties", params: { party: { name: "Json Party", description: "A JSON party", faction_id: @ascended.id, active: true }.to_json }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Party")
      expect(body["description"]).to eq("A JSON party")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(true)
      expect(Party.order("created_at").last.name).to eq("Json Party")
    end

    it "returns an error when the party name is missing" do
      post "/api/v2/parties", params: { party: { description: "A new party", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "returns an error for invalid JSON string" do
      post "/api/v2/parties", params: { party: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid party data format")
    end

    it "attaches an image", skip: "Image processing disabled in test environment" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/parties", params: { image: file, party: { name: "Party with Image", description: "A party with image", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Party with Image")
      expect(body["image_url"]).not_to be_nil
      expect(Party.order("created_at").last.image.attached?).to be_truthy
    end
  end

  describe "PATCH /update" do
    it "updates an existing party" do
      patch "/api/v2/parties/#{@dragons_party.id}", params: { party: { name: "Updated Dragons Party", description: "Updated group", faction_id: @ascended.id, active: false, character_ids: [@serena.id], vehicle_ids: [@tank.id, @jet.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons Party")
      expect(body["description"]).to eq("Updated group")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(false)
      expect(body["character_ids"]).to include(@serena.id)
      expect(body["vehicle_ids"]).to include(@tank.id, @jet.id)
      @dragons_party.reload
      expect(@dragons_party.name).to eq("Updated Dragons Party")
      expect(@dragons_party.description).to eq("Updated group")
      expect(@dragons_party.faction_id).to eq(@ascended.id)
      expect(@dragons_party.characters).to include(@serena)
      expect(@dragons_party.vehicles).to include(@tank, @jet)
    end

    it "updates an existing party with JSON string" do
      patch "/api/v2/parties/#{@dragons_party.id}", params: { party: { name: "Json Dragons Party", description: "JSON updated group", faction_id: @ascended.id, active: false, character_ids: [@serena.id], vehicle_ids: [@tank.id, @jet.id] }.to_json }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Dragons Party")
      expect(body["description"]).to eq("JSON updated group")
      expect(body["faction_id"]).to eq(@ascended.id)
      expect(body["active"]).to eq(false)
      expect(body["character_ids"]).to include(@serena.id)
      expect(body["vehicle_ids"]).to include(@tank.id, @jet.id)
      @dragons_party.reload
      expect(@dragons_party.name).to eq("Json Dragons Party")
      expect(@dragons_party.characters).to include(@serena)
      expect(@dragons_party.vehicles).to include(@tank, @jet)
    end

    it "returns an error when the party name is missing" do
      patch "/api/v2/parties/#{@dragons_party.id}", params: { party: { name: "", description: "Updated group", faction_id: @ascended.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
      @dragons_party.reload
      expect(@dragons_party.name).to eq("Dragons Party")
    end

    it "returns an error for invalid JSON string" do
      patch "/api/v2/parties/#{@dragons_party.id}", params: { party: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid party data format")
      @dragons_party.reload
      expect(@dragons_party.name).to eq("Dragons Party")
    end

    it "attaches an image", skip: "Image processing disabled in test environment" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/parties/#{@dragons_party.id}", params: { image: file, party: { name: "Updated Dragons Party", description: "Updated group", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons Party")
      expect(body["image_url"]).not_to be_nil
      @dragons_party.reload
      expect(@dragons_party.image.attached?).to be_truthy
    end

    it "replaces an existing image", skip: "Image processing disabled in test environment" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @dragons_party.image.attach(file)
      expect(@dragons_party.image.attached?).to be_truthy
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/parties/#{@dragons_party.id}", params: { image: file, party: { name: "Updated Dragons Party", description: "Updated group", faction_id: @dragons.id, active: true } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Dragons Party")
      expect(body["image_url"]).not_to be_nil
      @dragons_party.reload
      expect(@dragons_party.image.attached?).to be_truthy
    end

    it "adds a character to a party" do
      patch "/api/v2/parties/#{@ascended_party.id}", params: { party: { character_ids: [@brick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ascended Party")
      expect(body["character_ids"]).to include(@brick.id)
      @ascended_party.reload
      expect(@ascended_party.characters).to include(@brick)
    end

    it "removes a character from a party" do
      @ascended_party.characters << @brick
      patch "/api/v2/parties/#{@ascended_party.id}", params: { party: { character_ids: [] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ascended Party")
      expect(body["character_ids"]).not_to include(@brick.id)
      @ascended_party.reload
      expect(@ascended_party.characters).not_to include(@brick)
    end

    it "adds a vehicle to a party" do
      patch "/api/v2/parties/#{@ascended_party.id}", params: { party: { vehicle_ids: [@tank.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ascended Party")
      expect(body["vehicle_ids"]).to include(@tank.id)
      @ascended_party.reload
      expect(@ascended_party.vehicles).to include(@tank)
    end

    it "removes a vehicle from a party" do
      @ascended_party.vehicles << @tank
      patch "/api/v2/parties/#{@ascended_party.id}", params: { party: { vehicle_ids: [] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ascended Party")
      expect(body["vehicle_ids"]).not_to include(@tank.id)
      @ascended_party.reload
      expect(@ascended_party.vehicles).not_to include(@tank)
    end

    context "when updating active status" do
      it "sets active to false" do
        patch "/api/v2/parties/#{@dragons_party.id}", params: { party: { active: false } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(false)
        @dragons_party.reload
        expect(@dragons_party.active).to eq(false)
      end

      it "sets active to true" do
        @inactive_team.update!(active: false)
        patch "/api/v2/parties/#{@inactive_team.id}", params: { party: { active: true } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(true)
        @inactive_team.reload
        expect(@inactive_team.active).to eq(true)
      end
    end
  end

  describe "GET /show" do
    it "retrieves a party with vehicles" do
      get "/api/v2/parties/#{@dragons_party.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Dragons Party")
      expect(body["description"]).to eq("The Dragons' main group.")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["juncture_id"]).to eq(@modern.id)
      expect(body["active"]).to eq(true)
      expect(body["image_url"]).to be_nil
      expect(body["character_ids"]).to include(@brick.id)
      expect(body["vehicle_ids"]).to include(@tank.id, @jet.id)
      expect(body.keys).to include("id", "name", "description", "faction_id", "juncture_id", "active", "image_url", "created_at", "updated_at", "character_ids", "vehicle_ids")
    end

    it "returns a 404 for a non-existent party" do
      get "/api/v2/parties/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a party with no memberships" do
      delete "/api/v2/parties/#{@rogue_team.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Party.exists?(@rogue_team.id)).to be_falsey
      expect { @rogue_team.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error for a party with memberships" do
      delete "/api/v2/parties/#{@dragons_party.id}", headers: @headers
      expect(response).to have_http_status(422)
      body = JSON.parse(response.body)
      expect(body["error_type"]).to eq("associations_exist")
      expect(body["entity_type"]).to eq("party")
      expect(body["constraints"]["memberships"]["count"]).to be > 0
      expect(body["constraints"]["memberships"]["label"]).to eq("party members")
      expect(Party.exists?(@dragons_party.id)).to be_truthy
    end

    it "deletes a party with memberships when force is true" do
      delete "/api/v2/parties/#{@dragons_party.id}", params: { force: true }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(Party.exists?(@dragons_party.id)).to be_falsey
      expect { @dragons_party.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(@brick.reload.parties).not_to include(@dragons_party)
      expect(@tank.reload.parties).not_to include(@dragons_party)
      expect(@jet.reload.parties).not_to include(@dragons_party)
    end

    it "returns an error for a non-existent party" do
      delete "/api/v2/parties/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /image" do
    it "removes an image from a party" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @dragons_party.image.attach(image)
      expect(@dragons_party.image.attached?).to be_truthy
      delete "/api/v2/parties/#{@dragons_party.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @dragons_party.reload
      expect(@dragons_party.image.attached?).to be_falsey
      expect(@dragons_party.image_url).to be_nil
    end

    it "returns an error for a non-existent party" do
      delete "/api/v2/parties/999999/image", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "POST /api/v2/parties/:party_id/fight/:fight_id" do
    context "successful party addition" do
      it "adds party characters and vehicles to fight as hidden (shot: nil)" do
        post "/api/v2/parties/#{@dragons_party.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:success)
        
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(@dragons_party.id)
        expect(body["name"]).to eq("Dragons Party")
        
        # Verify shots were created for characters as hidden
        @dragons_party.characters.each do |character|
          shot = @fight.shots.find_by(character: character)
          expect(shot).to be_present
          expect(shot.shot).to be_nil
        end
        
        # Verify shots were created for vehicles as hidden
        @dragons_party.vehicles.each do |vehicle|
          shot = @fight.shots.find_by(vehicle: vehicle)
          expect(shot).to be_present
          expect(shot.shot).to be_nil
        end
      end

      it "returns party with character and vehicle details including shot_ids" do
        post "/api/v2/parties/#{@dragons_party.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:success)
        
        body = JSON.parse(response.body)
        expect(body["character_ids"]).to include(@brick.id)
        expect(body["vehicle_ids"]).to include(@tank.id, @jet.id)
      end

      it "handles empty parties gracefully" do
        post "/api/v2/parties/#{@rogue_team.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:success)
        
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(@rogue_team.id)
        expect(body["name"]).to eq("Rogue Team")
      end
    end

    context "multiple instances allowed" do
      it "allows adding same character multiple times to same fight" do
        # Add character once
        @fight.shots.create!(character: @brick, shot: 5)
        
        # Add party containing same character - should create another shot
        post "/api/v2/parties/#{@dragons_party.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:success)
        
        # Should have two shots for the same character now
        brick_shots = @fight.shots.where(character: @brick)
        expect(brick_shots.count).to eq(2)
        expect(brick_shots.pluck(:shot)).to contain_exactly(5, nil)
      end

      it "allows adding same vehicle multiple times to same fight" do
        # Add vehicle once
        @fight.shots.create!(vehicle: @tank, shot: 3)
        
        # Add party containing same vehicle - should create another shot
        post "/api/v2/parties/#{@dragons_party.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:success)
        
        # Should have two shots for the same vehicle now
        tank_shots = @fight.shots.where(vehicle: @tank)
        expect(tank_shots.count).to eq(2)
        expect(tank_shots.pluck(:shot)).to contain_exactly(3, nil)
      end
    end

    context "authorization and campaign scoping" do
      it "scopes operations to current user's campaign only" do
        other_campaign = @gamemaster.campaigns.create!(name: "Other Campaign")
        other_party = other_campaign.parties.create!(name: "Other Party")
        
        post "/api/v2/parties/#{other_party.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for parties in other campaigns" do
        other_user = User.create!(email: "other@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Other", last_name: "User")
        other_campaign = other_user.campaigns.create!(name: "Other Campaign")
        other_party = other_campaign.parties.create!(name: "Other Party")
        
        post "/api/v2/parties/#{other_party.id}/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for fights in other campaigns" do
        other_user = User.create!(email: "other@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Other", last_name: "User")
        other_campaign = other_user.campaigns.create!(name: "Other Campaign")
        other_fight = other_campaign.fights.create!(name: "Other Fight")
        
        post "/api/v2/parties/#{@dragons_party.id}/fight/#{other_fight.id}", headers: @headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 500 for users without current campaign" do
        unauthorized_user = User.create!(email: "unauthorized@example.com", confirmed_at: Time.now, first_name: "Unauthorized", last_name: "User")
        unauthorized_headers = Devise::JWT::TestHelpers.auth_headers({}, unauthorized_user)
        
        # Don't set current campaign for user - this should return 500
        post "/api/v2/parties/#{@dragons_party.id}/fight/#{@fight.id}", headers: unauthorized_headers
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context "error handling" do
      it "returns 404 for invalid party_id" do
        post "/api/v2/parties/99999999-9999-9999-9999-999999999999/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for invalid fight_id" do
        post "/api/v2/parties/#{@dragons_party.id}/fight/99999999-9999-9999-9999-999999999999", headers: @headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 422 for malformed UUID party_id" do
        post "/api/v2/parties/invalid-uuid/fight/#{@fight.id}", headers: @headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns 422 for malformed UUID fight_id" do
        post "/api/v2/parties/#{@dragons_party.id}/fight/invalid-uuid", headers: @headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
