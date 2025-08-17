require "rails_helper"
RSpec.describe "Api::V2::Users", type: :request do
  before(:each) do
    # players
    @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true, first_name: "Admin", last_name: "User")
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @inactive_user = User.create!(email: "inactive@example.com", confirmed_at: Time.now, active: false, first_name: "Inactive", last_name: "User")
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

  describe "GET /index" do
    context "when user is admin" do
      it "gets all active users" do
        get "/api/v2/users", headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq( ["player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "returns user attributes" do
        get "/api/v2/users", params: { search: "Player" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].length).to eq(1)
        expect(body["users"][0]).to include("email" => "player@example.com", "first_name" => "Player", "last_name" => "One", "admin" => nil, "gamemaster" => false)
        expect(body["users"][0].keys).to include("id", "email", "first_name", "last_name", "admin", "gamemaster", "image_url", "name", "created_at", "updated_at", "entity_class", "active", "campaigns")
      end

      it "sorts by created_at ascending" do
        get "/api/v2/users", params: { sort: "created_at", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "gamemaster@example.com", "player@example.com"])
      end

      it "sorts by created_at descending" do
        get "/api/v2/users", params: { sort: "created_at", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "sorts by updated_at ascending" do
        @admin.touch
        get "/api/v2/users", params: { sort: "updated_at", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["gamemaster@example.com", "player@example.com", "admin@example.com"])
      end

      it "sorts by updated_at descending" do
        @admin.touch
        get "/api/v2/users", params: { sort: "updated_at", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "player@example.com", "gamemaster@example.com"])
      end

      it "sorts by email ascending" do
        get "/api/v2/users", params: { sort: "email", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "gamemaster@example.com", "player@example.com"])
      end

      it "sorts by email descending" do
        get "/api/v2/users", params: { sort: "email", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "sorts by name ascending" do
        get "/api/v2/users", params: { sort: "name", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["gamemaster@example.com", "player@example.com", "admin@example.com"])
      end

      it "sorts by name descending" do
        get "/api/v2/users", params: { sort: "name", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "player@example.com", "gamemaster@example.com"])
      end

      it "filters by id" do
        get "/api/v2/users", params: { id: @player.id }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by email" do
        get "/api/v2/users", params: { email: "player@example.com" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by search string" do
        get "/api/v2/users", params: { search: "Player" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by search string" do
        get "/api/v2/users", params: { search: "Admin" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com"])
      end

      it "filters by character_id" do
        get "/api/v2/users", params: { character_id: @brick.id }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by character_id" do
        get "/api/v2/users", params: { character_id: @bandit.id }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["gamemaster@example.com"])
      end

      it "gets only active users when show_all is false" do
        get "/api/v2/users", params: { show_all: "false" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
        expect(body["users"].map { |u| u["email"] }).not_to include("inactive@example.com")
      end

      it "gets all users when show_all is true" do
        get "/api/v2/users", params: { show_all: "true" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["inactive@example.com", "player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "returns empty array when ids is explicitly empty" do
        get "/api/v2/users", params: { ids: "" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"]).to eq([])
      end
    end

    context "when user is not admin" do
      it "returns a forbidden error" do
        get "/api/v2/users", headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Admin access required")
      end
    end
  end

  describe "GET /autocomplete" do
    context "when user is admin" do
      it "gets all active users" do
        get "/api/v2/users", params: { autocomplete: true }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "returns user attributes" do
        get "/api/v2/users", params: { autocomplete: true, search: "Player" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].length).to eq(1)
        expect(body["users"][0]).to include("email" => "player@example.com")
        expect(body["users"][0].keys).to eq(["id", "name", "email", "entity_class"])
      end

      it "sorts by created_at ascending" do
        get "/api/v2/users", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "gamemaster@example.com", "player@example.com"])
      end

      it "sorts by created_at descending" do
        get "/api/v2/users", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "sorts by updated_at ascending" do
        @admin.touch
        get "/api/v2/users", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["gamemaster@example.com", "player@example.com", "admin@example.com"])
      end

      it "sorts by updated_at descending" do
        @admin.touch
        get "/api/v2/users", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "player@example.com", "gamemaster@example.com"])
      end

      it "sorts by email ascending" do
        get "/api/v2/users", params: { autocomplete: true, sort: "email", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "gamemaster@example.com", "player@example.com"])
      end

      it "sorts by email descending" do
        get "/api/v2/users", params: { autocomplete: true, sort: "email", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "sorts by name ascending" do
        get "/api/v2/users", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["gamemaster@example.com", "player@example.com", "admin@example.com"])
      end

      it "sorts by name descending" do
        get "/api/v2/users", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com", "player@example.com", "gamemaster@example.com"])
      end

      it "filters by id" do
        get "/api/v2/users", params: { autocomplete: true, id: @player.id }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by email" do
        get "/api/v2/users", params: { autocomplete: true, email: "player@example.com" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by search string" do
        get "/api/v2/users", params: { autocomplete: true, search: "Player" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by search string" do
        get "/api/v2/users", params: { autocomplete: true, search: "Admin" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["admin@example.com"])
      end

      it "filters by character_id" do
        get "/api/v2/users", params: { autocomplete: true, character_id: @brick.id }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com"])
      end

      it "filters by character_id" do
        get "/api/v2/users", params: { autocomplete: true, character_id: @bandit.id }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["gamemaster@example.com"])
      end

      it "gets only active users when show_all is false" do
        get "/api/v2/users", params: { autocomplete: true, show_all: "false" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["player@example.com", "gamemaster@example.com", "admin@example.com"])
        expect(body["users"].map { |u| u["email"] }).not_to include("inactive@example.com")
      end

      it "gets all users when show_all is true" do
        get "/api/v2/users", params: { autocomplete: true, show_all: "true" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"].map { |u| u["email"] }).to eq(["inactive@example.com", "player@example.com", "gamemaster@example.com", "admin@example.com"])
      end

      it "returns empty array when ids is explicitly empty" do
        get "/api/v2/users", params: { autocomplete: true, ids: "" }, headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["users"]).to eq([])
      end
    end

    context "when user is not admin" do
      it "returns a forbidden error" do
        get "/api/v2/users", params: { autocomplete: true }, headers: @player_headers
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Admin access required")
      end
    end
  end
end
