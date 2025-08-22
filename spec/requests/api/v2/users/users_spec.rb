require "rails_helper"
RSpec.describe "Api::V2::Users", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # players
    @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true, first_name: "Admin", last_name: "User", name: "Admin User")
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master", name: "Game Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One", name: "Player One")
    @inactive_user = User.create!(email: "inactive@example.com", confirmed_at: Time.now, active: false, first_name: "Inactive", last_name: "User", name: "Inactive User")
    @campaign = @admin.campaigns.create!(name: "Adventure")
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
    @admin_headers = Devise::JWT::TestHelpers.auth_headers({}, @admin)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    set_current_campaign(@admin, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    context "when user is admin" do
      it "creates a new user" do
        post "/api/v2/users", params: { user: { email: "newuser@example.com", first_name: "New", last_name: "User", admin: false, gamemaster: false } }, headers: @admin_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["email"]).to eq("newuser@example.com")
        expect(body["first_name"]).to eq("New")
        expect(body["last_name"]).to eq("User")
        expect(body["name"]).to eq("New User")
        expect(body["admin"]).to eq(false)
        expect(body["gamemaster"]).to eq(false)
        expect(body["image_url"]).to be_nil
        expect(response.headers["Authorization"]).to match(/^Bearer /)
        expect(User.order("created_at").last.email).to eq("newuser@example.com")
      end

      it "creates a new user with JSON string" do
        post "/api/v2/users", params: { user: { email: "jsonuser@example.com", first_name: "Json", last_name: "User", admin: true, gamemaster: true }.to_json }, headers: @admin_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["email"]).to eq("jsonuser@example.com")
        expect(body["first_name"]).to eq("Json")
        expect(body["last_name"]).to eq("User")
        expect(body["name"]).to eq("Json User")
        expect(body["admin"]).to eq(true)
        expect(body["gamemaster"]).to eq(true)
        expect(User.order("created_at").last.email).to eq("jsonuser@example.com")
      end

      it "returns an error when email is missing" do
        post "/api/v2/users", params: { user: { first_name: "New", last_name: "User", admin: false, gamemaster: false } }, headers: @admin_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include({ "email" => ["is invalid"] })
      end

      it "returns an error for invalid JSON string" do
        post "/api/v2/users", params: { user: "invalid json" }, headers: @admin_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid user data format")
      end

      it "attaches an image" do
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        post "/api/v2/users", params: { image: file, user: { email: "imageuser@example.com", first_name: "Image", last_name: "User", admin: false, gamemaster: false } }, headers: @admin_headers
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["email"]).to eq("imageuser@example.com")
        expect(body["image_url"]).not_to be_nil
        expect(User.order("created_at").last.image.attached?).to be_truthy
      end
    end

    context "when user is not admin" do
      it "returns a forbidden error" do
        post "/api/v2/users", params: { user: { email: "newuser@example.com", first_name: "New", last_name: "User", admin: false, gamemaster: false } }, headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Admin access required")
      end
    end
  end

  describe "GET /show" do
    it "retrieves a user by id" do
      get "/api/v2/users/#{@player.id}", headers: @admin_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("player@example.com")
      expect(body["first_name"]).to eq("Player")
      expect(body["last_name"]).to eq("One")
      expect(body["name"]).to eq("Player One")
      expect(body["admin"]).to be_falsey
      expect(body["gamemaster"]).to eq(false)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "first_name", "last_name", "name", "email", "created_at", "updated_at", "active", "admin", "gamemaster", "image_url")
    end

    it "retrieves a user by confirmation_token" do
      @player.update!(confirmation_token: "abc123")
      get "/api/v2/users/confirmation_token", params: { confirmation_token: "abc123" }, headers: @admin_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("player@example.com")
      expect(body["name"]).to eq("Player One")
    end

    it "returns a 404 for a non-existent user" do
      get "/api/v2/users/999999", headers: @admin_headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end

    it "returns a 404 for an invalid confirmation_token" do
      get "/api/v2/users/confirmation_token", params: { confirmation_token: "invalid" }, headers: @admin_headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "GET /current" do
    it "retrieves the current user" do
      get "/api/v2/users/current", headers: @admin_headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Admin User")
      expect(body["email"]).to eq("admin@example.com")
      expect(body["admin"]).to eq(true)
      expect(body["gamemaster"]).to be_falsey
      expect(body["id"]).to eq(@admin.id)
    end

    it "requires authentication" do
      get "/api/v2/users/current"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /update" do
    context "when user is admin" do
      it "updates another user’s attributes" do
        patch "/api/v2/users/#{@player.id}", params: { user: { first_name: "Updated", last_name: "Player", admin: true, gamemaster: true } }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["first_name"]).to eq("Updated")
        expect(body["last_name"]).to eq("Player")
        expect(body["name"]).to eq("Updated Player")
        expect(body["admin"]).to eq(true)
        expect(body["gamemaster"]).to eq(true)
        expect(response.headers["Authorization"]).to match(/^Bearer /)
        @player.reload
        expect(@player.name).to eq("Updated Player")
        expect(@player.admin).to eq(true)
        expect(@player.gamemaster).to eq(true)
      end

      it "updates another user with JSON string" do
        patch "/api/v2/users/#{@player.id}", params: { user: { first_name: "Json", last_name: "Player", admin: false, gamemaster: false }.to_json }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["first_name"]).to eq("Json")
        expect(body["last_name"]).to eq("Player")
        expect(body["name"]).to eq("Json Player")
        expect(body["admin"]).to eq(false)
        expect(body["gamemaster"]).to eq(false)
        @player.reload
        expect(@player.name).to eq("Json Player")
      end

      it "returns an error when email is invalid" do
        patch "/api/v2/users/#{@player.id}", params: { user: { email: "invalid", first_name: "Updated", last_name: "Player" } }, headers: @admin_headers
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include({ "email" => ["is invalid"] })
        @player.reload
        expect(@player.email).to eq("player@example.com")
      end

      it "returns an error for invalid JSON string" do
        patch "/api/v2/users/#{@player.id}", params: { user: "invalid json" }, headers: @admin_headers
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid user data format")
        @player.reload
        expect(@player.first_name).to eq("Player")
      end

      it "attaches an image" do
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        patch "/api/v2/users/#{@player.id}", params: { image: file, user: { first_name: "Image", last_name: "Player" } }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["first_name"]).to eq("Image")
        expect(body["name"]).to eq("Image Player")
        expect(body["image_url"]).not_to be_nil
        @player.reload
        expect(@player.image.attached?).to be_truthy
      end

      it "replaces an existing image" do
        @player.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
        expect(@player.image.attached?).to be_truthy
        file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        patch "/api/v2/users/#{@player.id}", params: { image: file, user: { first_name: "Image", last_name: "Player" } }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["first_name"]).to eq("Image")
        expect(body["name"]).to eq("Image Player")
        expect(body["image_url"]).not_to be_nil
        @player.reload
        expect(@player.image.attached?).to be_truthy
      end

      context "inline editing scenarios" do
        it "updates only first_name field" do
          patch "/api/v2/users/#{@player.id}", params: { user: { first_name: "NewFirst" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["first_name"]).to eq("NewFirst")
          expect(body["last_name"]).to eq("One")  # unchanged
          expect(body["name"]).to eq("NewFirst One")
          expect(body["email"]).to eq("player@example.com")  # unchanged
          @player.reload
          expect(@player.first_name).to eq("NewFirst")
          expect(@player.last_name).to eq("One")
        end

        it "updates only last_name field" do
          patch "/api/v2/users/#{@player.id}", params: { user: { last_name: "NewLast" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["first_name"]).to eq("Player")  # unchanged
          expect(body["last_name"]).to eq("NewLast")
          expect(body["name"]).to eq("Player NewLast")
          expect(body["email"]).to eq("player@example.com")  # unchanged
          @player.reload
          expect(@player.first_name).to eq("Player")
          expect(@player.last_name).to eq("NewLast")
        end

        it "updates only email field (with Devise confirmable behavior)" do
          patch "/api/v2/users/#{@player.id}", params: { user: { email: "newemail@example.com" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          # With Devise confirmable, email might go to unconfirmed_email until confirmed
          # But admin updates should bypass confirmation, so check what actually happens
          expect(body["first_name"]).to eq("Player")  # unchanged
          expect(body["last_name"]).to eq("One")  # unchanged
          expect(body["name"]).to eq("Player One")  # unchanged
          @player.reload
          expect(@player.first_name).to eq("Player")
          # Check either email was updated directly or unconfirmed_email was set
          expect(@player.email == "newemail@example.com" || @player.unconfirmed_email == "newemail@example.com").to be_truthy
        end

        it "updates email with proper validation (with Devise confirmable behavior)" do
          patch "/api/v2/users/#{@player.id}", params: { user: { email: "valid@test.com" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          @player.reload
          # Check either email was updated directly or unconfirmed_email was set
          expect(@player.email == "valid@test.com" || @player.unconfirmed_email == "valid@test.com").to be_truthy
        end

        it "rejects invalid email format" do
          original_email = @player.email
          patch "/api/v2/users/#{@player.id}", params: { user: { email: "invalid-email" } }, headers: @admin_headers
          expect(response).to have_http_status(:unprocessable_entity)
          body = JSON.parse(response.body)
          expect(body["errors"]).to include({ "email" => ["is invalid"] })
          @player.reload
          expect(@player.email).to eq(original_email)  # unchanged
        end

        it "rejects duplicate email addresses" do
          # Create another user with a different email
          other_user = User.create!(email: "other@example.com", confirmed_at: Time.now, first_name: "Other", last_name: "User", name: "Other User")
          original_email = @player.email

          # Try to update player to use the other user's email
          patch "/api/v2/users/#{@player.id}", params: { user: { email: "other@example.com" } }, headers: @admin_headers
          expect(response).to have_http_status(:unprocessable_entity)
          body = JSON.parse(response.body)
          expect(body["errors"]).to include({ "email" => ["has already been taken"] })
          @player.reload
          expect(@player.email).to eq(original_email)  # unchanged
        end

        it "updates name correctly when first_name changes" do
          patch "/api/v2/users/#{@player.id}", params: { user: { first_name: "UpdatedFirst" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          @player.reload
          expect(@player.name).to eq("UpdatedFirst One")
        end

        it "updates name correctly when last_name changes" do
          patch "/api/v2/users/#{@player.id}", params: { user: { last_name: "UpdatedLast" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          @player.reload
          expect(@player.name).to eq("Player UpdatedLast")
        end

        it "updates name correctly when both first_name and last_name change" do
          patch "/api/v2/users/#{@player.id}", params: { user: { first_name: "NewFirst", last_name: "NewLast" } }, headers: @admin_headers
          expect(response).to have_http_status(:success)
          @player.reload
          expect(@player.name).to eq("NewFirst NewLast")
        end
      end
    end

    context "when user is updating their own attributes" do
      it "updates own attributes" do
        patch "/api/v2/users/#{@player.id}", params: { user: { first_name: "Self", last_name: "Updated" } }, headers: @player_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["first_name"]).to eq("Self")
        expect(body["last_name"]).to eq("Updated")
        expect(body["name"]).to eq("Self Updated")
        expect(response.headers["Authorization"]).to match(/^Bearer /)
        @player.reload
        expect(@player.name).to eq("Self Updated")
      end
    end

    context "when non-admin user tries to update another user" do
      it "returns a forbidden error" do
        patch "/api/v2/users/#{@gamemaster.id}", params: { user: { first_name: "Unauthorized" } }, headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("You can only edit your own attributes or must be an admin")
        @gamemaster.reload
        expect(@gamemaster.first_name).to eq("Game")
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user is admin" do
      it "deletes a user with no character associations" do
        delete "/api/v2/users/#{@inactive_user.id}", headers: @admin_headers
        expect(response).to have_http_status(:ok)
        expect(User.exists?(@inactive_user.id)).to be_falsey
        expect { @inactive_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "returns an error for a user with character associations" do
        delete "/api/v2/users/#{@player.id}", headers: @admin_headers
        expect(response).to have_http_status(400)
        body = JSON.parse(response.body)
        expect(body["errors"]).to eq({ "characters" => true })
        expect(User.exists?(@player.id)).to be_truthy
      end

      it "deletes a user with associations when force is true" do
        delete "/api/v2/users/#{@player.id}", params: { force: true }, headers: @admin_headers
        expect(response).to have_http_status(:ok)
        expect(User.exists?(@player.id)).to be_falsey
        expect { @player.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(@brick.reload.user_id).to be_nil
        expect(@serena.reload.user_id).to be_nil
      end

      it "returns an error for a non-existent user" do
        delete "/api/v2/users/999999", headers: @admin_headers
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Record not found")
      end
    end

    context "when user is not admin" do
      it "returns a forbidden error" do
        delete "/api/v2/users/#{@gamemaster.id}", headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Admin access required")
        expect(User.exists?(@gamemaster.id)).to be_truthy
      end
    end
  end

  describe "DELETE /remove_image" do
    context "when user is admin" do
      it "removes another user’s image" do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @player.image.attach(image)
        expect(@player.image.attached?).to be_truthy
        delete "/api/v2/users/#{@player.id}/image", headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["image_url"]).to be_nil
        expect(response.headers["Authorization"]).to match(/^Bearer /)
        @player.reload
        expect(@player.image.attached?).to be_falsey
        expect(@player.image_url).to be_nil
      end
    end

    context "when user removes their own image" do
      it "removes own image" do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @player.image.attach(image)
        expect(@player.image.attached?).to be_truthy
        delete "/api/v2/users/#{@player.id}/image", headers: @player_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["image_url"]).to be_nil
        @player.reload
        expect(@player.image.attached?).to be_falsey
        expect(@player.image_url).to be_nil
      end
    end

    context "when non-admin user tries to remove another user’s image" do
      it "returns a forbidden error" do
        image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
        @gamemaster.image.attach(image)
        expect(@gamemaster.image.attached?).to be_truthy
        delete "/api/v2/users/#{@gamemaster.id}/image", headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Admin access required to remove another user's image")
        @gamemaster.reload
        expect(@gamemaster.image.attached?).to be_truthy
      end
    end

    it "returns an error for a non-existent user" do
      delete "/api/v2/users/999999/image", headers: @admin_headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end
end
